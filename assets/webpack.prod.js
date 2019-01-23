const webpack = require('webpack')
const Merge = require('webpack-merge')
const CommonConfig = require('./webpack.common.js')
const ImageminPlugin = require('imagemin-webpack-plugin').default
const UglifyJSPlugin = require('uglifyjs-webpack-plugin')

const webpackProdConfig = Merge(CommonConfig, {
  devtool: 'source-map',
  mode: 'production',

  plugins: [
    new ImageminPlugin({
      disable: true,
      pngquant: {
        quality: '95-100'
      },
      test: /\.(jpe?g|png|gif|svg)$/i
    })
  ],
  optimization: {
    minimizer: [
      new UglifyJSPlugin({
        uglifyOptions: {
          output: {
            comments: false
          },
          minify: {},
          compress: {
            unused: true,
            dead_code: true,
            warnings: false
          }
        }
      })
    ]
  }
})

module.exports = webpackProdConfig
