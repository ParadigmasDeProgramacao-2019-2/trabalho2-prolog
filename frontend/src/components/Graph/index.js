
import React, { Component } from 'react';
import Graph from "react-graph-vis";
import axios from 'axios';
 
export default class DrawGraph extends Component {

  state = {
    topological: [],
    disciplines: [],
    graph: {nodes: [], edges: []},
  }

  async componentDidMount(){

        let response;
    
        try {
          response = await axios.get('http://localhost:3333/');
        } catch(e){
          response = await axios.get('http://localhost:3333/');
        }
      
        console.log(response.data);

        this.setState({
          topological: response.data.topological,
          disciplines: response.data.disciplines
        });

        this.renderNodes();

        console.log(this.state);
  }

  renderNodes = () => {
    let aux_vector = [];
    let nodes = [];
    let edges = [];

    this.state.disciplines.forEach(item => {
        if(aux_vector.indexOf(item.pre) === -1){
          aux_vector.push(item.pre); 
          nodes.push({ id: item.pre , label: `${item.pre}`});
        }

        if(aux_vector.indexOf(item.actual) === -1){
          aux_vector.push(item.actual); 
          nodes.push({ id: item.actual , label: `${item.actual}`});
        }

        edges.push({from: item.pre, to: item.actual});
    });

    console.log(nodes);

    this.setState({...this.state, graph: {nodes, edges}});
  }
 
  options = {
    layout: {
      hierarchical: true
    },
    edges: {
      color: "#000000"
    },
    height: "800px",
    physics: {
      enabled: true
    },
    interaction: { multiselect: true, dragView: true }
  };
 
  events = {
    select: function(event) {
      var { nodes, edges } = event;
    }
  };

  render(){

    console.log(this.graph);

    return (
      <Graph
        graph={this.state.graph}
        options={this.options}
        events={this.events}
        getNetwork={network => {//  if you want access to vis.js network api you can set the state in a parent component using this property
        }}
      />
    );
  }
}
 