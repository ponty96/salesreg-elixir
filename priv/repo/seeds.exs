# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     SalesReg.Repo.insert!(%SalesReg.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
use SalesRegWeb, :context

tags = [
  "#love",
  "#instagood",
  "#tgif",
  "#tbt",
  "#picoftheday",
  "#instalike",
  "#igers",
  "#follow4follow",
  "#instamood",
  "#family",
  "#nofilter"
]

real_product_params = [
    ["35000", "2312", "500", "https://www-konga-com-res.cloudinary.com/w_auto,f_auto,fl_lossy,dpr_auto,q_auto/media/catalog/product/W/M/118566_1520434157.jpg", "Tecno Camon CX"],
    ["4550", "2453", "415", "https://www-konga-com-res.cloudinary.com/w_auto,f_auto,fl_lossy,dpr_auto,q_auto/media/catalog/product/Q/O/145324_1544634354.jpg", "Iphone 3 Smart Case"],
    ["105000", "1231", "83", "https://www-konga-com-res.cloudinary.com/w_auto,f_auto,fl_lossy,dpr_auto,q_auto/media/catalog/product/E/Z/63606_1544882088.jpg", "Samsung Galaxy A7"],
    ["9500", "1212", "123", "https://www-konga-com-res.cloudinary.com/w_auto,f_auto,fl_lossy,dpr_auto,q_auto/media/catalog/product/Y/Y/146712_1544771683.jpg", "Samsung Wireless Charger"],
    ["192000", "342", "42", "https://www-konga-com-res.cloudinary.com/w_auto,f_auto,fl_lossy,dpr_auto,q_auto/media/catalog/product/H/J/79345_1544269510.jpg", "Samsung Galaxy A9"],
    ["35000", "543", "64", "https://www-konga-com-res.cloudinary.com/w_auto,f_auto,fl_lossy,dpr_auto,q_auto/media/catalog/product/N/B/79345_1544267899.jpg", "Samsung Galaxy J2 Core"],
    ["74000", "531", "111", "https://www-konga-com-res.cloudinary.com/w_auto,f_auto,fl_lossy,dpr_auto,q_auto/media/catalog/product/U/C/127129_1544582689.jpg", "Tecno Camon 11"],
    ["7000", "534", "102", "https://www-konga-com-res.cloudinary.com/w_auto,f_auto,fl_lossy,dpr_auto,q_auto/media/catalog/product/F/Z/146712_1544771430.jpg", "Zealot E1 wireless Bluetooth"],
    ["5000", "3642", "122", "https://www-konga-com-res.cloudinary.com/w_auto,f_auto,fl_lossy,dpr_auto,q_auto/media/catalog/product/T/W/139874_1544760438.jpg", "A1 Smartwatch"],
    ["3500", "5436", "653", "https://www-konga-com-res.cloudinary.com/w_auto,f_auto,fl_lossy,dpr_auto,q_auto/media/catalog/product/R/R/145324_1544633862.jpg", "iPhone Screen Protector"],
    ["565000", "3552", "852", "https://www-konga-com-res.cloudinary.com/w_auto,f_auto,fl_lossy,dpr_auto,q_auto/media/catalog/product/C/U/138088_1544715357.jpg", "Apple iPhone Xs Max"],
    ["30000", "3500", "564", "https://www-konga-com-res.cloudinary.com/w_auto,f_auto,fl_lossy,dpr_auto,q_auto/media/catalog/product/A/R/113242_1544460268.jpg", "Rechargeable iPhone X Batter Case"],
    ["2500", "2342", "232", "https://www-konga-com-res.cloudinary.com/w_auto,f_auto,fl_lossy,dpr_auto,q_auto/media/catalog/product/H/B/72113_1523955564.jpg", "Sony AC Adapter Power Supply"],
    ["129000", "1242", "232", "https://www-konga-com-res.cloudinary.com/w_auto,f_auto,fl_lossy,dpr_auto,q_auto/media/catalog/product/Z/X/142283_1544366793.jpg", "Tecno Phatom 8"],
    ["91000", "1242", "332", "https://www-konga-com-res.cloudinary.com/w_auto,f_auto,fl_lossy,dpr_auto,q_auto/media/catalog/product/B/U/142283_1544365503.jpg", "Tecno Camon S Pro Bordeaux"]
  ]

  real_service_params = [
    ["Fumigation and Pest Service", "6000", "https://s3.amazonaws.com/www.dealdey.com/system/deals/listing_images/410582/S234x146/SERVICE-Chogon-Facilities-Services---LS403.jpg?1543762261"],
    ["Complete Car Wash | Home or Office", "4000", "https://s3.amazonaws.com/www.dealdey.com/system/deals/listing_images/410508/S234x146/c700x420.jpg?1543513084"],
    ["Professional Logo Design", "10000", "https://s3.amazonaws.com/www.dealdey.com/system/deals/listing_images/410397/S234x146/115371_4664345_779240_image.jpg?1543310073"],
    ["Teeth Polishing", "7000", "https://s3.amazonaws.com/www.dealdey.com/system/deals/listing_images/410458/S234x146/Teeth-1.jpg?1543431924"],
    ["Teeth Replacement", "10000", "https://s3.amazonaws.com/www.dealdey.com/system/deals/listing_images/410439/S234x146/Dental-Care.jpg?1543333885"],
    ["Xmas Spa Treat", "12000", "https://s3.amazonaws.com/www.dealdey.com/system/deals/listing_images/410512/S234x146/Spakools-Spa-1.jpg?1543513846"],
    ["Building Your Leadership Skills", "15000", "https://s3.amazonaws.com/www.dealdey.com/system/deals/listing_images/410323/S234x146/thth.png?1543239464"],
    ["Digital Marketing", "50000", "https://s3.amazonaws.com/www.dealdey.com/system/deals/listing_images/410249/S234x146/img_20170608_162058.jpg?1543220242"],
    ["Microsoft Excel Training", "25000", "https://s3.amazonaws.com/www.dealdey.com/system/deals/listing_images/410507/S234x146/excel-Training.png?1543512846"],
    ["Professional Web Development", "300000", "https://s3.amazonaws.com/www.dealdey.com/system/deals/listing_images/409833/S234x146/Webp.net-resizeimage.jpg?1542740066"],
    ["Human Resource Management", "30000", "https://s3.amazonaws.com/www.dealdey.com/system/deals/listing_images/409824/S234x146/HRM-Dashboa.jpg?1542739116"],
    ["Online HSE Training", "60000", "https://s3.amazonaws.com/www.dealdey.com/system/deals/listing_images/410451/S234x146/RISKID-event-SHE.jpg?1543397362"],
    ["Emotional Intelligence", "38000", "https://s3.amazonaws.com/www.dealdey.com/system/deals/listing_images/410324/S234x146/success-ei.jpg?1543239597"],
    ["Buld SMS", "1,500", "https://s3.amazonaws.com/www.dealdey.com/system/deals/listing_images/410252/S234x146/bulksms_2.png?1543220922"],
    ["Quality Assurance and Quality Control", "40000", "https://s3.amazonaws.com/www.dealdey.com/system/deals/listing_images/410250/S234x146/qaqc_pix_DEALDEY.jpg?1543220485"]
  ]


  {:ok, _template} = Seed.add_template()
  {:ok, user} = Seed.create_user()
  {:ok, company} = Seed.create_company(user.id)
# {:ok, template} = Seed.add_template()
# {:ok, company_template} = Seed.add_company_template(company.id, user.id, template.id)

products = Enum.map(real_product_params, fn(params) ->
  {:ok, product} = Seed.add_product_without_variant(params, company.id, user.id)
  product
end)

# Enum.map(1..5, fn _index ->
#   Seed.add_product_with_variant(company, user)
# end)

# categories =
#   Enum.map(1..25, fn _index ->
#     {:ok, category} = Seed.add_category(company.id, user.id)
#     category.id
#   end)

services =
  Enum.map(real_service_params, fn(params) ->
    {:ok, service} = Seed.add_service(params, company.id, user.id)
    service
  end)

{:ok, customer} = Seed.add_contact(user.id, company.id, "customer")

# vendors =
#   Enum.map(1..25, fn _index ->
#     {:ok, vendor} = Seed.add_contact(user.id, company.id, "vendor")
#     vendor
#   end)

# Enum.map(1..20, fn _index ->
#   Seed.add_expense(user.id, company.id)
# end)

# templates =
#   Enum.map(1..5, fn _index ->
#     {:ok, templates} = Seed.add_template()
#     templates
#   end)

# Seed.add_company_template(company.id, user.id, template.id)

# branch =
#   Repo.all(Branch)
#   |> Enum.random()

# random_vendors = Enum.take_random(vendors, 8)
# random_customers = Enum.take_random(customers, 8)

Seed.create_sales_order(company.id, user.id, customer.id, %{items: products, type: "product"})

Seed.create_sales_order(company.id, user.id, customer.id, %{items: services, type: "service"})

# Enum.map(random_customers, fn customer ->
#   Seed.create_sales_order(company.id, user.id, customer.id, %{items: services, type: "service"})
# end)

# # Enum.map(random_customers, fn customer ->
# #   Seed.create_sales_order(company.id, user.id, customer.id, products, services)
# # end)

Enum.map(1..10, fn _index ->
  Seed.create_bank(company.id)
end)

# sale_order =
#   SalesReg.Order.processed_sale_orders()
#   |> Enum.random()

# {:ok, invoice} = Seed.create_invoice(sale_order)

# Seed.create_receipt(invoice.id, user.id, company.id)



