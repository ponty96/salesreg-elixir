use SalesRegWeb, :context

sales = Repo.all(Sale)
invoices = Repo.all(Invoice)
receipts = Repo.all(Receipt)

Enum.map(sales, fn sale ->
  sale = Order.preload_order(sale)
  %{
    company_id: sale.company_id,
    actor_id: sale.user_id,
    message: "A new order has been created for #{sale.contact.contact_name}"
  }
  |> Notifications.create_notification({:order, sale}, :created)
end)

Enum.map(invoices, fn invoice ->
  invoice = Order.preload_invoice(invoice)
  %{
    company_id: invoice.company_id,
    actor_id: invoice.user_id,
    message: "An invoice has been created for #{invoice.sale.contact.contact_name}"
  }
  |> Notifications.create_notification({:invoice, invoice}, :created)
end)

Enum.map(receipts, fn receipt ->
  receipt = Order.preload_receipt(receipt)
  %{
    company_id: receipt.company_id,
    actor_id: receipt.user_id,
    message: "A sum of ##{receipt.amount_paid} was paid by #{receipt.sale.contact.contact_name}"
  }
  |> Notifications.create_notification({:invoice, receipt.invoice}, :payment)
end)

resources = sales ++ invoices ++ receipts

update_notifications = fn resources ->
  Enum.map(resources, fn resource ->
    from(n in Notification,
      where: n.element_id == ^resource.id,
      update: [set: [inserted_at: ^resource.inserted_at]],
      update: [set: [updated_at: ^resource.updated_at]]
    )
    |> Repo.update_all([])
  end)
end

update_notifications.(resources)