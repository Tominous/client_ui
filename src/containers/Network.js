import React, {Component} from 'react';
import {grey400} from 'material-ui/styles/colors';
import PageBase from '../components/PageBase';

const styles = {
  toggleDiv: {
    maxWidth: 300,
    marginTop: 40,
    marginBottom: 5
  },
  toggleLabel: {
    color: grey400,
    fontWeight: 100
  },
  buttons: {
    marginTop: 30,
    float: 'right'
  },
  saveButton: {
    marginLeft: 5
  }
};

class Network extends Component {

  componentDidMount() {
    for (let index = 0; index < document.getElementsByClassName('menu-button').length; index++) {
      document.getElementsByClassName('menu-button')[index].classList.remove('active');
    }
    document.getElementsByClassName('menu-button')[1].classList.add('active');
  }

  render() { 
    return ( <div>Network</div> );
  }
}


export default Network;
