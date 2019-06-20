import React, {Component} from 'react';


class Settings extends Component {

  componentDidMount() {
    for (let index = 0; index < document.getElementsByClassName('menu-button').length; index++) {
      document.getElementsByClassName('menu-button')[index].classList.remove('active');
    }
    document.getElementsByClassName('menu-button')[5].classList.add('active');
  }

  render() { 
    return ( <div>Settings</div> );
  }
}


export default Settings;
