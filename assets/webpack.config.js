const path = require("path");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const webpack = require("webpack");

const dev = {
  output: {
    path: path.resolve(__dirname, "public"),
    filename: "app.js",
    publicPath: "http://localhost:8080/"
  },
  css: [
    "style-loader",
    { loader: "css-loader", options: { modules: true } },
    "sass-loader"
  ],
  plugins: []
};

const prod = {
  output: {
    path: path.resolve(__dirname, "../priv/static/"),
    filename: "app.js",
    publicPath: "/"
  },
  css: [
    MiniCssExtractPlugin.loader,
    {
      loader: "css-loader",
      options: {
        modules: true,
        sourceMap: true,
        localIdentName: "[local]__[hash:base64:5]"
      }
    },
    "sass-loader"
  ],
  plugins: [
    new MiniCssExtractPlugin({
      filename: "app.css"
    })
  ]
};

module.exports = function webpacker() {
  const production = process.env.NODE_ENV === "production";
  const options = production ? prod : dev;

  return {
    devtool: production ? "source-maps" : "eval",
    devServer: {
      headers: {
        "Access-Control-Allow-Origin": "*"
      }
    },
    entry: "./js/app.js",
    output: options.output,
    module: {
      rules: [
        {
          test: /\.jsx?$/,
          exclude: /node_modules/,
          use: {
            loader: "babel-loader"
          }
        },
        {
          test: /\.scss$/,
          use: options.css
        }
      ]
    },
    plugins: [
      new webpack.DefinePlugin({
        "process.env.NODE_ENV": JSON.stringify(process.env.NODE_ENV),
        API_ENDPOINT: "https://localhost:4000"
      }),
      ...options.plugins
    ],
    resolve: {
      modules: ["node_modules", path.resolve(__dirname, "js")],
      extensions: [".js", ".jsx"]
    }
  };
};
