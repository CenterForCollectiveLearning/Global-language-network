import React from "react";
import {Network} from "d3plus-react";

import booksNetwork from "../data/books_network.json";
import twitterNetwork from "../data/twitter_network.json";
import wikiNetwork from "../data/wikipedia_network.json";

import "./Visualizations.scss";

export default class Visualizations extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      type: "books"
    }
  }
  render() {
    console.log(booksNetwork);
    console.log(new Set(booksNetwork.data.map(d => d["Family Name"])))
    const familyToColor = {
      'Afro-Asiatic': '#CC6680',
    'Altaic': '#9CFF9C',
    'Amerindian': '#4E994E',
    'Austronesian': '#FF87FF',
    'Caucasian': '#BAFEFF',
    'Creoles and pidgins': '#9933FF',
    'Dravidian': '#F7E406',
    'Indo-European': '#7470FF',
    'Niger-Kordofanian': '#FF6666',
    'Other': '#999999',
    'Sino-Tibetan': '#E67E5A',
    'Tai': '#FFFF00',
    'Uralic': '#9999FF'
  };
  const {type} = this.state;
  const data = type === "books" ? booksNetwork : type === "wiki" ? wikiNetwork : twitterNetwork;

    return <div>
      <div>
        <button onClick={() => this.setState({type: "books"})}>Books</button>
        <button onClick={() => this.setState({type: "twitter"})}>Twitter</button>
        <button onClick={() => this.setState({type: "wiki"})}>Wikipedia</button>
      </div>
      <div><Network config={{
        data: data.data,
        nodes: data.nodes,
        links: data.edges,
        size: d => d["Number of Speakers (millions)"],
        shapeConfig: {
          Circle: {
            fill: d => familyToColor[d["Family Name"]]
          }
        },
        sizeMin: 2,
        sizeMax: 24,
        height: 500,
        width: 800
      }} /></div>
    </div>
  }
}