import React, {Component} from 'react';
import Services from '../services/services';

class Landing extends Component {

  constructor(props) {
    super(props);
    this.state = {
      isNew: false,
      accounts: []
    };
  }
  componentDidMount() {
    let that = this;
    Services.onload()
    .then(function(res){
      that.setState({accounts: res.accounts});
    }) 
    for (let index = 0; index < document.getElementsByClassName('menu-button').length; index++) {
      document.getElementsByClassName('menu-button')[index].classList.remove('active');
    }
  }

  render() { 
    return ( <div></div> );
  }
}


export default Landing;
