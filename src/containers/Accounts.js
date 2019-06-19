import React, {Component} from 'react';
import {grey400} from 'material-ui/styles/colors';
import Data from '../data';
import ContentCreate from 'material-ui/svg-icons/content/create';

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
  },
  columns: {
    name: {
      width: '70%',
      padding: '10px',
      color: 'rgb( 89, 89, 89 )',
    },
    view: {
      width: '15%',
      padding: '10px',
      color: 'rgb( 89, 89, 89 )',
    },
    delete: {
      width: '15%',
      padding: '10px',
      color: 'rgb( 89, 89, 89 )',
    }
  },
  tableContainer: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center'
  },
  tableContent: {
    width: '65%',
    backgroundColor: 'white',
    border: 'solid 2px rgb( 200, 200, 200 )',
    borderRadius: '10px'
  },
  tableRow: {
    backgroundColor: 'rgb( 211, 241, 219 )',
    margin:10,
    display: 'flex'
  },
  newTableRow: {
    backgroundColor: 'rgb( 127, 127, 127 )',
    margin:10,
    display: 'flex'
  },
  buttonRow: {
    display: 'flex',
    width: '65%'
  },
  keyButton: {
    backgroundColor:'rgb( 249, 201, 196 )',
    width: '50%',
    justifyContent: 'center',
    display: 'flex',
    padding: '10px',
    borderRadius: '11px',
    margin: '5px',
    color: 'rgb( 89, 89, 89 )'
  }
};

class Accounts extends Component {

  constructor(props) {
      super(props);
      this.state = {
        isNew: false
      }
  }
  componentDidMount() {
    for (let index = 0; index < document.getElementsByClassName('menu-button').length; index++) {
      document.getElementsByClassName('menu-button')[index].classList.remove('active');
    }
    document.getElementsByClassName('menu-button')[0].classList.add('active');
  }

  viewItem() {
    alert('view');
  }

  createItem() {
    alert('create');
  }

  deleteItem() {
    alert('delete');
  }

  newKey() {
    this.setState({isNew: true});
  }
  uploadKey() {
    alert("upload");
  }
  render() { 
    return (
      <div style={styles.tableContainer}>
          <div style={styles.buttonRow}>
            <div style={styles.keyButton} onClick={this.newKey}>
              new key pair
            </div>
            <div style={styles.keyButton} onClick={this.uploadKey}>
              upload key pair
            </div>
          </div>
          <div style={styles.tableContent}>
            {Data.accountPage.items.map(item =>
              <div key={item.id} style={styles.tableRow}>
                <div style={styles.columns.name}>{item.name}</div>
                <div style={styles.columns.view} onClick={this.viewItem}>
                  View
                </div>
                <div style={styles.columns.delete} onClick={this.deleteItem}>
                  Delete       
                </div>
              </div>
            )}
            {this.state.isNew&&
              <div style={styles.newTableRow}>
                <div style={styles.columns.name}>
                  <input/>
                </div>
                <div style={styles.columns.view} onClick={this.createItem}>
                  create
                </div>
                <div style={styles.columns.delete} onClick={this.deleteItem}>
                  del       
                </div>
              </div>            
            }
          </div>  
      </div>
     );
  }
}

export default Accounts;
