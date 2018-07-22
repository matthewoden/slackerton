import React from "react";
import style from "./main.scss";

export default class Main extends React.Component {
  render() {
    console.log(style);
    return <div className={style.body}>Hello</div>;
  }
}
