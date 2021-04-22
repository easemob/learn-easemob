
const path = require("path");
// gzip压缩
const CompressionWebpackPlugin = require('compression-webpack-plugin')
const UglifyJsPlugin = require('uglifyjs-webpack-plugin');//配置代码压缩
const isProduction = process.env.NODE_ENV === 'production';// 是否为生产环境
function resolve(dir) {
    return path.join(__dirname, dir)
}
module.exports = {
    outputDir: 'dist',// 打包输出文件目录
    lintOnSave: false, //eslint-loader 是否开启eslint
    productionSourceMap:false,// 是否在构建生产包时生成 sourceMap 文件，false将提高构建速度
    devServer:{
        open:true,
        host: '0.0.0.0',
        port: 8080,
        https: false,
        hotOnly: false,
        proxy:null// 设置代理
    },
    // 第三方插件配置
    pluginOptions: {
     
    },
    chainWebpack: config => {
        // 移除 prefetch 插件
        config.plugins.delete('prefetch')
        // 移除 preload 插件
        config.plugins.delete('preload');
         // 生产环境配置
         if (isProduction) {
            // 删除预加载
            config.plugins.delete('preload');
            config.plugins.delete('prefetch');
            // 压缩代码
            config.optimization.minimize(true);
            // 分割代码
            config.optimization.splitChunks({
                chunks: 'all'
            });
            // ============压缩图片 start============
            config.module
            .rule('images')
            .use('image-webpack-loader')
            .loader('image-webpack-loader')
            .options({ bypassOnDebug: true })
            .end()
        // ============压缩图片 end============
        }
    },
    configureWebpack: config => {
        if (isProduction) {
            // 为生产环境修改配置...
            const productionGzipExtensions = ['html', 'js', 'css'] // gzip压缩
            config.plugins.push(
                //生产环境自动删除console
                // new UglifyJsPlugin({
                //     uglifyOptions: {
                //         compress: {
                //             warnings: false,// 若打包错误，则注释这行
                //             drop_debugger: true,
                //             drop_console: true,
                //             pure_funcs: ['console.log']
                //         },
                //     },
                //     sourceMap: false,
                //     parallel: true,
                // }),
                // gzip压缩
                new CompressionWebpackPlugin({
                    filename: '[path].gz[query]',
                    algorithm: 'gzip',
                    test: new RegExp(
                        '\\.(' + productionGzipExtensions.join('|') + ')$'
                    ),
                    threshold: 10240, // 只有大小大于该值的资源会被处理 10240
                    minRatio: 0.8, // 只有压缩率小于这个值的资源才会被处理
                    deleteOriginalAssets: false // 删除原文件
                }),
            );
        } else {
            // 为开发环境修改配置...
        }
    }
}