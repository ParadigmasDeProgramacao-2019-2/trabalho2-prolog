
import React, { Component } from 'react';
import Graph from "react-graph-vis";
import axios from 'axios';
 
export default class DrawGraph extends Component {

  state = {
    topological: [],
    disciplines: []
  }

  async componentDidMount(){

        let response;
    
        try {
          response = await axios.get('http://localhost:3333/?habilitation=123');
        } catch(e){
          response = await axios.get('http://localhost:3333/?habilitation=123');
        }
      
        this.setState({
          topological: response.data.topological,
          disciplines: response.data.disciplines
        });

        console.log(this.state);
  }

  graph = {
    nodes: [
      { id: 1, label: "Node 1", color: "#e04141" },
      { id: 2, label: "Node 2", title: "node 2 tootip text" },
      { id: 3, label: "Node 3", title: "node 3 tootip text" },
      { id: 4, label: "Node 4", title: "node 4 tootip text" },
      { id: 5, label: "Node 5", title: "node 5 tootip text" }
    ],
    edges: [
      { from: 1, to: 2 },
      { from: 1, to: 3 },
      { from: 2, to: 4 },
      { from: 2, to: 5 }
    ]
  };
 
  options = {
    layout: {
      hierarchical: true
    },
    edges: {
      color: "#000000"
    },
    height: "800px"
  };
 
  events = {
    select: function(event) {
      var { nodes, edges } = event;
    }
  };

  render(){
    return (
      <Graph
        graph={this.graph}
        options={this.options}
        events={this.events}
        getNetwork={network => {//  if you want access to vis.js network api you can set the state in a parent component using this property
        }}
      />
    );
  }
}
 