import React, {Component} from 'react';

const styles = {
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

  tableRow: {
    backgroundColor: 'rgb( 211, 241, 219 )',
    margin:10,
    display: 'flex',
    borderRadius: 5
  },



  ///////////////////////////////////
  container: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center'
  },
  content: {
    backgroundColor: 'white',
    border: 'solid 2px rgb( 200, 200, 200 )',
    borderRadius: '10px'
  },
  keyButton: {
    backgroundColor:'rgb( 249, 201, 196 )',
    width: '24%',
    justifyContent: 'center',
    display: 'flex',
    padding: '10px',
    borderRadius: '11px',
    margin: '5px',
    color: 'rgb( 89, 89, 89 )'
  },
  label: {
    width: '34%',
    justifyContent: 'flex-start',
    display: 'flex',
    padding: '10px',
    borderRadius: '11px',
    margin: '5px',
    color: 'rgb( 89, 89, 89 )'
  },
  buttonRow: {
    display: 'flex',
    justifyContent: 'space-between'
  },
  grayRow: {
    backgroundColor: 'rgb( 127, 127, 127 )',
    margin:10,
    display: 'flex',
    borderRadius: 5,
    justifyContent: 'space-between'    
  },
};

class Contracts extends Component {

  componentDidMount() {
    for (let index = 0; index < document.getElementsByClassName('menu-button').length; index++) {
      document.getElementsByClassName('menu-button')[index].classList.remove('active');
    }
    document.getElementsByClassName('menu-button')[2].classList.add('active');
  }

  render() { 
    return ( 
      <div style={styles.container}>
        <div style={styles.buttonRow} className="content">
          <div style={styles.label}>
            payment contracts
          </div>
          <div className="btn" style={styles.keyButton} onClick={this.uploadKey}>
            upload
          </div>
        </div>
        <div style={styles.content} className="content">
          <div style={styles.grayRow}>
            <div style={styles.columns.name}>
              name
            </div>
            <div className="btn" style={styles.columns.delete} onClick={this.deleteItem}>
              del       
            </div>
          </div>   
          <div style={styles.grayRow}>
            <div style={styles.columns.name}>
              name
            </div>
            <div className="btn" style={styles.columns.delete} onClick={this.deleteItem}>
              del       
            </div>
          </div>   
        </div>
        <div style={styles.buttonRow} className="content">
          <div style={styles.label}>
            session contracts
          </div>
          <div className="btn" style={styles.keyButton} onClick={this.uploadKey}>
            upload
          </div>
        </div>
        <div style={styles.content} className="content">
          <div style={styles.grayRow}>
            <div style={styles.columns.name}>
              name
            </div>
            <div className="btn" style={styles.columns.delete} onClick={this.deleteItem}>
              del       
            </div>
          </div>   
          <div style={styles.grayRow}>
            <div style={styles.columns.name}>
              name
            </div>
            <div className="btn" style={styles.columns.delete} onClick={this.deleteItem}>
              del       
            </div>
          </div>   
        </div>
      </div>
    );
  }
}


export default Contracts;
