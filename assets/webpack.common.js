const CleanWebpackPlugin = require('clean-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');
const ExtractTextPlugin = require('extract-text-webpack-plugin');
const path = require('path');
const webpack = require('webpack');
const { CheckerPlugin } = require('awesome-typescript-loader');

module.exports = {
	entry: {
		app: [ './js/app.tsx', './css/app.scss' ]
	},

	output: {
		path: path.join(__dirname + '/../priv/static/'),
		filename: 'js/[name].js',
		sourceMapFilename: '[file].map'
	},

	// Enable sourcemaps for debugging webpack's output.
	devtool: 'source-map',

	resolve: {
		extensions: [ '.ts', '.tsx', '.js', '.jsx' ],
		modules: [ 'node_modules', __dirname + '/static/js' ],
		alias: {
			'@': path.resolve('./js')
		}
	},

	optimization: {
		splitChunks: {
			cacheGroups: {
				default: false,
				vendors: false,
				vendor: {
					name: 'vendor',
					chunks: 'all',
					test: /node_modules/,
					priority: 20
				},

				common: {
					name: 'common',
					minChunks: 2,
					chunks: 'all',
					priority: 10,
					reuseExistingChunk: true,
					enforce: true
				}
			}
		}
	},

	module: {
		rules: [
			{
				test: /\.tsx?$/,
				loader: 'awesome-typescript-loader',
				options: {
					emitRequireType: false
				}
			},
			{
				enforce: 'pre',
				test: /\.js$/,
				loader: 'source-map-loader',
				exclude: [
					// these packages have problems with their sourcemaps
					path.resolve(__dirname + '/node_modules/bootstrap')
				]
			},
			{
				test: /\.jsx?$/,
				exclude: /node_modules/,
				loader: 'babel-loader',
				query: {
					presets: [ 'react', 'env' ]
				}
			},
			{
				test: /\.css$/,
				loader: ExtractTextPlugin.extract({
					fallback: 'style-loader',
					use: [ 'css-loader?SourceMap', 'postcss-loader?SourceMap' ]
				})
			},
			{
				test: /\.scss$/,
				loader: ExtractTextPlugin.extract({
					fallback: 'style-loader',
					use: [ 'css-loader', 'postcss-loader', 'sass-loader?SourceMap' ]
				})
			},
			// Font Definitions
			// removed limit=10000
			{
				test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
				loader: 'url-loader?name=fonts/[name].[ext]&mimetype=application/font-woff'
			},
			{
				test: /\.(ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
				loader: 'url-loader?name=fonts/[name].[ext]'
			},
			// Image Definitions
			{
				test: /\.(gif|png|jpe?g|svg|ico)$/i,
				loader: 'url-loader?limit=8192?name=[name]-[hash:6].[ext]&outputPath=images/'
			},
			{
				test: /bootstrap\/dist\/js\/umd\//,
				use: 'imports-loader?jQuery=jquery'
			}
		]
	},
	plugins: [
		new CheckerPlugin(),
		new CleanWebpackPlugin([ path.resolve(__dirname, '../priv/static') ]),
		new CopyWebpackPlugin([
			{
				from: __dirname + '/static/'
			},
			{
				from: __dirname + '/fonts/',
				to: 'fonts/'
			}
		]),
		new ExtractTextPlugin({
			filename: 'css/app.css',
			disable: false,
			allChunks: true
		}),
		new webpack.LoaderOptionsPlugin({
			options: {
				context: __dirname,
				url: false
			}
		})
	]
};
