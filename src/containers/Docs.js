import React, {Component} from 'react';


class Docs extends Component {

  componentDidMount() {
    for (let index = 0; index < document.getElementsByClassName('menu-button').length; index++) {
      document.getElementsByClassName('menu-button')[index].classList.remove('active');
    }
    document.getElementsByClassName('menu-button')[6].classList.add('active');
  }

  render() { 
    return ( <div>Docs</div> );
  }
}


export default Docs;
