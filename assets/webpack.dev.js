const webpack = require('webpack')
const Merge = require('webpack-merge')
const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin
const CommonConfig = require('./webpack.common.js')

const webpackDevConfig = Merge(CommonConfig, {
	devtool: 'cheap-module-eval-source-map',
	mode: 'development'
})

module.exports = function(env = {}) {
	if (env.runAnalyzer) {
		webpackDevConfig.plugins.push(
			new BundleAnalyzerPlugin({
				analyzerMode: 'static',
				openAnalyzer: true
			})
		)
	}
	return webpackDevConfig
}
