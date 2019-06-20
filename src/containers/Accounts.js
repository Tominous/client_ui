import React, {Component} from 'react';
import Services from '../services/services';

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
      width: '80%',
      padding: '10px',
      color: 'rgb( 89, 89, 89 )',
    },
    view: {
      width: '10%',
      padding: '10px',
      color: 'rgb( 89, 89, 89 )',
    },
    delete: {
      width: '10%',
      padding: '10px',
      color: 'rgb( 89, 89, 89 )',
    }
  },
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
  rowItem: {
    backgroundColor: 'rgb( 230, 236, 244 )',
    margin:10,
    display: 'flex',
    borderRadius: 5,
    justifyContent: 'space-between'
  },
  newrowItem: {
    backgroundColor: 'rgb( 127, 127, 127 )',
    margin:10,
    display: 'flex',
    justifyContent: 'space-between',
    borderRadius: 5
  },
  buttonRow: {
    display: 'flex',
    justifyContent: 'flex-end'
  },
  keyButton: {
    backgroundColor:'rgb( 249, 201, 196 )',
    width: '25%',
    justifyContent: 'center',
    display: 'flex',
    padding: '10px',
    borderRadius: '11px',
    margin: '5px',
    color: 'rgb( 89, 89, 89 )'
  },
  cancelButton: {
    backgroundColor:'rgb( 220, 220, 220 )',
    width: '25%',
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

  formItem: {
    backgroundColor: 'rgb(252, 252, 252)',
    margin:10,
    display: 'flex',
    borderRadius: 5,
    justifyContent: 'space-between',
    alignItems: 'center'
  },
  input: {
    padding: 6,
    borderRadius: 6,
    width:200,
    float: 'right',
    height: 26
  },
  formLabel: {
    justifyContent: 'flex-start',
    display: 'flex',
    padding: '10px',
    borderRadius: '11px',
    margin: '5px',
    color: 'rgb( 89, 89, 89 )'
  },

};

class Accounts extends Component {

  constructor(props) {
      super(props);
      this.state = {
        isNew: false,
        newName: '',
        keyFile: '',
        keyList: [],
        newModal: false,
        balence: '',
        validationError: false
      };
      this.newKey = this.newKey.bind(this);
      this.createAccount = this.createAccount.bind(this);
      this.viewItem = this.viewItem.bind(this);
      this.deleteItem = this.deleteItem.bind(this);
      this.handleChange = this.handleChange.bind(this);
      this.handleSubmit = this.handleSubmit.bind(this);
      this.uploadKeyfile = this.uploadKeyfile.bind(this);
      this.closeModal = this.closeModal.bind(this);
  }
  componentDidMount() {
    let that = this;
    Services.onload()
    .then(function(res){
      console.log("res", res);
      that.setState({keyList: res.accounts});
    }) 

    for (let index = 0; index < document.getElementsByClassName('menu-button').length; index++) {
      document.getElementsByClassName('menu-button')[index].classList.remove('active');
    }
    document.getElementsByClassName('menu-button')[0].classList.add('active');
  }

  viewItem(key) {
    alert(key);
    // Services.onload()
    // .then(function(res){
    //   console.log("res", res);
    //   res.json().then(function (params) {
    //     console.log('params', params);
    //     this.setState({keyList: params});
    //   })
    // }) 
  }

  createAccount() {
    if (this.state.newName!==""&&this.state.balence!=="") {
      let accountInfo = {name: this.state.newName, balance: this.state.balence};
      let that = this;
      Services.createAccount(accountInfo)
      .then(function(res){
        that.closeModal();
        let newValue = { name: accountInfo.name, publicKey: res.publicKey};
        that.state.keyList.push(newValue);
        that.setState({keyList: that.state.keyList});
      }) 
    } else {
      this.setState({validationError: true});
    }
  }

  deleteItem() {
    let keyInfo = {name: ''};
    Services.deleteKey(keyInfo)
    .then(function(res){
      console.log("res", res);
    }) 
  }

  newKey() {
    this.setState({newModal: true});
    let modal = document.getElementById("create-account");
    let new_name = document.getElementById("new-name");
    modal.style.display = "block";
    new_name.focus();
  }


  handleChange(e) {
    let val = {};
    val[e.target.name] = e.target.value;
    this.setState(val);
  }

  handleSubmit(event) {
    console.log(this.state.newName);
    event.preventDefault();
  }

  uploadKeyfile(e) {
    this.setState({keyFile: e.target.value, isNew: true});
  }

  closeModal() {
    this.setState({validationError: false});
    var modal = document.getElementById("create-account");
    modal.style.display = "none";
  }

  render() {
    return (
      <div style={styles.container}>
          <div style={styles.buttonRow} className="content">
            <div className="btn" style={styles.keyButton} onClick={this.newKey}>
              new
            </div>
          </div>
          <div style={styles.content} className="content">
            {this.state.keyList.map(item =>
              <div key={item.id} style={styles.rowItem}>
                <div style={styles.columns.name}>{item.name}</div>
                <div className="btn txt" style={styles.columns.view} onClick={()=>this.viewItem(item.publicKey)}>
                  key
                </div>
                <div className="btn txt" style={styles.columns.delete} onClick={this.deleteItem}>
                  del       
                </div>
              </div>
            )}
          </div>
          <div id="create-account" className="modal">
            <div className="modal-content">
              <div className="modal-header">
                <span className="close" onClick={this.closeModal}>&times;</span>
                <h2>create new account</h2>
              </div>
              <div className="modal-body">
                <div style={styles.formItem}>
                  <div style={styles.formLabel}>name:</div>
                  <input style={styles.input} id="new-name" name="newName" value={this.state.newName} onChange={this.handleChange}/>
                </div>
                <div style={styles.formItem}>
                  <div style={styles.formLabel}>initial balence:</div>
                  <input style={styles.input} type="number" name="balence" value={this.state.balence} onChange={this.handleChange}/>
                </div>
                {this.state.validationError&&<div style={{display: 'flex',justifyContent: 'center'}}><span className="validation">"name” and “initial balance” must be specified’</span></div>}
              </div>
              <div className="modal-footer">
                <div className="btn" style={styles.keyButton} onClick={this.createAccount}>
                  create       
                </div>
                <div className="btn" style={styles.cancelButton} onClick={this.closeModal}>
                  cancel       
                </div>
              </div>
            </div>
          </div>
      </div>
     );
  }
}

export default Accounts;
