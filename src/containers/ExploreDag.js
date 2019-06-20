import React, {Component} from 'react';


class ExploreDag extends Component {

  componentDidMount() {
    for (let index = 0; index < document.getElementsByClassName('menu-button').length; index++) {
      document.getElementsByClassName('menu-button')[index].classList.remove('active');
    }
    document.getElementsByClassName('menu-button')[4].classList.add('active');
  }

  render() { 
    return ( <div>ExploreDag</div> );
  }
}


export default ExploreDag;
