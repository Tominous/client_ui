import React, {Component} from 'react';
import Services from '../services/services';
import data from '../data'

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
    margin: '5px',
    color: 'rgb( 89, 89, 89 )'
  },
  cancelButton: {
    backgroundColor:'rgb( 220, 220, 220 )',
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
        newModal: false,
        balance: '',
        validationError: false,
        data: data.data
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
    let data = JSON.parse(localStorage.getItem("data"));
    this.setState({data: data});

    for (let index = 0; index < document.getElementsByClassName('menu-button').length; index++) {
      document.getElementsByClassName('menu-button')[index].classList.remove('active');
    }
    document.getElementsByClassName('menu-button')[0].classList.add('active');
  }

  viewItem(key) {
    alert(key);
  }

  createAccount() {
    if (this.state.newName!==""&&this.state.balance!=="") {
      let accountInfo = {name: this.state.newName, balance: this.state.balance};
      let that = this;
      Services.createAccount(accountInfo)
      .then(function(res){
        that.closeModal();
        let newValue = { name: accountInfo.name, publicKey: res.publicKey};
        that.state.data.accounts.push(newValue);
        that.setState({data: that.state.data});
        localStorage.setItem("data", JSON.stringify(that.state.data));
      }) 
    } else {
      this.setState({validationError: true});
    }
  }

  deleteItem(name, i) {
    let keyInfo = {name: name};
    let that = this;
    Services.deleteAccount(keyInfo)
    .then(function(res){
      if (res.status) {
        that.state.data.accounts.splice(i, 1);
        that.setState({data: that.state.data});
        localStorage.setItem("data", JSON.stringify(that.state.data));        
      }
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
            {this.state.data.accounts.map((item, i)=>
              <div key={item.id} style={styles.rowItem}>
                <div style={styles.columns.name}>{item.name}</div>
                <div className="btn txt" style={styles.columns.view} onClick={()=>this.viewItem(item.publicKey)}>
                  key
                </div>
                <div className="btn txt" style={styles.columns.delete} onClick={()=>this.deleteItem(item.name, i)}>
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
                  <div style={styles.formLabel}>initial balance:</div>
                  <input style={styles.input} type="number" name="balance" value={this.state.balance} onChange={this.handleChange}/>
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
