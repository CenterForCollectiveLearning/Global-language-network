import React from "react";
import {Network} from "d3plus-react";

import booksNetwork from "../data/books_network.json";
import twitterNetwork from "../data/twitter_network.json";
import wikiNetwork from "../data/wikipedia_network.json";

import "./Visualizations.scss";

function shadeColor(color, percent) {

  var R = parseInt(color.substring(1,3),16);
  var G = parseInt(color.substring(3,5),16);
  var B = parseInt(color.substring(5,7),16);

  R = parseInt(R * (100 + percent) / 100);
  G = parseInt(G * (100 + percent) / 100);
  B = parseInt(B * (100 + percent) / 100);

  R = (R<255)?R:255;  
  G = (G<255)?G:255;  
  B = (B<255)?B:255;  

  var RR = ((R.toString(16).length===1)?"0"+R.toString(16):R.toString(16));
  var GG = ((G.toString(16).length===1)?"0"+G.toString(16):G.toString(16));
  var BB = ((B.toString(16).length===1)?"0"+B.toString(16):B.toString(16));

  return "#"+RR+GG+BB;
}

export default class Visualizations extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      type: "books",
      width: 20,
      height: 20
    }
  }

  componentDidMount() {
    const width = window.innerWidth;
    const height = window.innerHeight;
    this.setState({height, width});
  }

  render() {
    const {height, type, width} = this.state;
    
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

  const data = type === "books" ? booksNetwork : type === "wiki" ? wikiNetwork : twitterNetwork;

    return <div>
      <div>
        <button className={type === "books" ? "selected" : ""} onClick={() => this.setState({type: "books"})}>Books</button>
        <button className={type === "twitter" ? "selected" : ""} onClick={() => this.setState({type: "twitter"})}>Twitter</button>
        <button className={type === "wiki" ? "selected" : ""} onClick={() => this.setState({type: "wiki"})}>Wikipedia</button>
      </div>
      <div><Network config={{
        data: data.data,
        nodes: data.nodes,
        links: data.edges,
        height: height - 50,
        width: width - 30,
        label: d => d["Language Code"],
        linkSize: d => d.opacity,
        linkSizeMin: 1,
        linkSizeMax: 20,
        size: d => d["Number of Speakers (millions)"],
        tooltipConfig: {
          title: d => d["Language Name"],
          tbody: d => [
            ["Number of Speakers (millions)", d["Number of Speakers (millions)"]],
            ["Family Name", d["Family Name"]],
            ["GDP per Capita (dollars)", d["GDP per Capita (dollars)"]]
          ]
        },
        shapeConfig: {
          label: d => d["Language Code"],
          labelConfig: {
            fontMin: 1
          },
          Circle: {
            label: d => d["Language Code"],
            strokeWidth: d => 2,
            stroke: d => shadeColor(familyToColor[d["Family Name"]], -20),
            fill: d => familyToColor[d["Family Name"]]
          },
          Line: {
            strokeColor: "#222222"
          }
        },
        sizeMin: 2,
        sizeMax: 24
      }} /></div>
    </div>
  }
}