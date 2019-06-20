import React, {Component} from 'react';


class Landing extends Component {

  componentDidMount() {
    for (let index = 0; index < document.getElementsByClassName('menu-button').length; index++) {
      document.getElementsByClassName('menu-button')[index].classList.remove('active');
    }
  }

  render() { 
    return ( <div></div> );
  }
}


export default Landing;
