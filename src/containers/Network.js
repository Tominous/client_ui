import React, {Component} from 'react';


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
