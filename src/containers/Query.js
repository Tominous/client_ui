import React, {Component} from 'react';


class Query extends Component {

  componentDidMount() {
    for (let index = 0; index < document.getElementsByClassName('menu-button').length; index++) {
      document.getElementsByClassName('menu-button')[index].classList.remove('active');
    }
    document.getElementsByClassName('menu-button')[3].classList.add('active');
  }

  render() { 
    return ( <div>Query</div> );
  }
}


export default Query;
