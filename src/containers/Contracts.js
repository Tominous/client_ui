import React, {Component} from 'react';
import Services from '../services/services';

const styles = {

  columns: {
    name: {
      width: '80%',
      padding: '10px',
      color: 'rgb( 89, 89, 89 )',
    },
    view: {
      padding: '10px',
      color: 'rgb( 89, 89, 89 )',
    },
    delete: {
      padding: '10px',
      color: 'rgb( 89, 89, 89 )',
    }
  },
  container: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center'
  },
  content: {
    backgroundColor: 'white',
    border: 'solid 2px rgb( 200, 200, 200 )',
    borderRadius: '10px'
  },
  keyButton: {
    backgroundColor:'rgb( 249, 201, 196 )',
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
    color: 'rgb( 89, 89, 89 )',
    fontWeight: 'bold'
  },
  buttonRow: {
    display: 'flex',
    justifyContent: 'space-between',
    marginTop: '14px'
  },
  grayRow: {
    backgroundColor: 'rgb( 230, 236, 244 )',
    margin:10,
    display: 'flex',
    borderRadius: 5,
    justifyContent: 'space-between'    
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
    float: 'right',
    height: 26,
    width: '100%'
  },
  cancelButton: {
    backgroundColor:'rgb( 220, 220, 220 )',
    margin: '5px',
    color: 'rgb( 89, 89, 89 )'
  },
  browseButton: {
    backgroundColor:'rgb( 230, 236, 244 )',
    marginTop: '15px',
    color: 'rgb( 89, 89, 89 )'
  },
  center: {
    width: '100%',
    justifyContent: 'center'
  }
};

class Contracts extends Component {

  constructor(props) {
    super(props);
    this.state = {
      payment: '',
      validationError: false,
      contractType: 'payment',
      newName: '',
      wasmContent: '',
      paymentArg: '',
      sessionArg: '',
      paymentItem: '',
      sessionItem: '',
      savedContractItem: '',
      data: {
              accounts: [],
              payment: [],
              session: [],
              savedContracts: [],
              savedDeploys: []
            },
      // data: {
      //   accounts: [],
      //   payment: ["payment1", "payment2", "payment3", "payment4"],
      //   session: ["session1", "session2", "session3", "session4"],
      //   savedContracts: [
      //       {name:"saved contract1", payment: 'payment1', session: 'session1', paymentArgs: 'paymentArg1', sessionArgs: "sessionArg1"},
      //       {name:"saved contract2", payment: 'payment2', session: 'session2', paymentArgs: 'paymentArg2', sessionArgs: "sessionArg2"},
      //       {name:"saved contract3", payment: 'payment3', session: 'session3', paymentArgs: 'paymentArg3', sessionArgs: "sessionArg3"},
      //     ],
      //   savedDeploys: []
      // },
      // savedContracts: [
      //   {name: '', }
      // ]
    };
    this.handleChange = this.handleChange.bind(this);
    this.uploadPaymentContract = this.uploadPaymentContract.bind(this);
    this.uploadSessionContract = this.uploadSessionContract.bind(this);
    this.closeModal = this.closeModal.bind(this);
    this.uploadFile = this.uploadFile.bind(this);
    this.createNewContract = this.createNewContract.bind(this);
    this.readWasm = this.readWasm.bind(this);
    this.selectPayment = this.selectPayment.bind(this);
    this.deployContract = this.deployContract.bind(this);
  }

  componentDidMount() {
    let data = JSON.parse(localStorage.getItem("data"));
    this.setState({data: data});
    for (let index = 0; index < document.getElementsByClassName('menu-button').length; index++) {
      document.getElementsByClassName('menu-button')[index].classList.remove('active');
    }
    document.getElementsByClassName('menu-button')[2].classList.add('active');
  }

  handleChange(e) {
    let val = {};
    val[e.target.name] = e.target.value;
    this.setState(val);
  }

  uploadPaymentContract() {
    this.setState({newModal: true});
    this.setState({contractType: "payment"});    
    let modal = document.getElementById("upload-contract-modal");
    let contract_name = document.getElementById("contract-name");
    modal.style.display = "block";
    contract_name.focus();
  }

  uploadSessionContract() {
    this.setState({newModal: true});
    this.setState({contractType: "session"});
    let modal = document.getElementById("upload-contract-modal");
    let contract_name = document.getElementById("contract-name");
    modal.style.display = "block";
    contract_name.focus();
  }

  closeModal() {
    this.setState({validationError: false});
    var modal = document.getElementById("upload-contract-modal");
    modal.style.display = "none";
  }

  uploadFile() {
    var wasmFile = document.getElementById("wasm-file");
    wasmFile.click();
  }

  readWasm(e) {
    let reader = new FileReader();
    let that = this;
    reader.onload = function() {
      let wasmContent = btoa(unescape(encodeURIComponent(reader.result)))
      that.setState({wasmContent: wasmContent});
    }    
    reader.readAsText(e.target.files[0]);
  }


  createNewContract() {
    if (this.state.newName==''||this.state.wasmContent=='') {
      this.setState({validationError: true});
      return;
    }

    let contractInfo = {name: this.state.newName, type: this.state.contractType, wasm: this.state.wasmContent};
    let that = this;
    Services.storeContract(contractInfo)
    .then(function(res){
      that.closeModal();
      console.log("result ===== ", res)
      if (res.status) {
        if (that.state.contractType=="payment") {
          that.state.data.payment.push(that.state.newName);   
        } else {
          that.state.data.session.push(that.state.newName);   
        }
        that.setState({});
        localStorage.setItem('data', that.state.data);
      }
    }) 
  }

  selectPayment(paymentName) {
    this.setState({savedContractItem: ''});
    this.setState({paymentItem: paymentName});
  }

  selectSession(sessionName) {
    this.setState({savedContractItem: ''});    
    this.setState({sessionItem: sessionName});
  }

  selectContract(contractItem) {
    this.setState({sessionItem: ''});    
    this.setState({paymentItem: ''});    
    this.setState({savedContractItem: contractItem});
  }

  deployContract() {
    let contractInfo = {};
    if ((this.state.paymentItem==''||this.state.sessionItem=='')&&this.state.savedContractItem=='') {
      alert('payment and session contracts must be specified');
      return;
    } else if (this.state.paymentItem==''||this.state.sessionItem=='') {
      contractInfo = this.state.savedContractItem;
    } else {
      contractInfo = {
        payment: this.state.paymentItem,
        paymentArgs: this.state.paymentArg,
        session: this.state.sessionItem,
        sessionArgs: this.state.sessionArg
      };      
    }
    contractInfo.account = "MDAwMDAwMDAwMDAwMDAwMDAwMDA=";
      Services.deployContract(contractInfo)
      .then(function(res){
        console.log("result ===== ", res)
      })
  }

  savedDeploy(savedContractItem, i) {
    console.log(i);
    let contractInfo = savedContractItem;
    contractInfo.account = "MDAwMDAwMDAwMDAwMDAwMDAwMDA=";
    Services.deployContract(contractInfo)
    .then(function(res){
      console.log("result ===== ", res)
    })
  }

  saveContract() {
    let contractInfo = {};
    if (this.state.paymentItem==''||this.state.sessionItem=='') {
      alert('payment and session contracts must be specified');
      return;
    } 
      contractInfo = {
        payment: this.state.paymentItem,
        paymentArgs: this.state.paymentArg,
        session: this.state.sessionItem,
        sessionArgs: this.state.sessionArg,
        account: "MDAwMDAwMDAwMDAwMDAwMDAwMDA="
      };      
      Services.saveContract(contractInfo)
      .then(function(res){
        console.log("result ===== ", res)
      })
  }

  deleteContract(contractItem, i) {
    console.log(i);
    console.log(contractItem);
  }

  deleteItem(item, type, i) {
    Services.deleteContract({name: item})
    .then(function(res) {
      console.log(res);
      if (type=='session') {
        this.state.data.session.splice(i, 1);
      } else {
        this.state.data.payment.splice(i, 1);
      }
      this.setState({data: this.state.data});
    })
  }

  render() { 
    const {payment, session, savedContracts} = this.state.data;
    return ( 
      <div>
        <div className="row">
          <div className="col-xs-12 col-sm-6 col-md-6 col-lg-6 col-md m-b-15">
            <div style={styles.buttonRow}>
              <div style={styles.label}>
                payment contracts
              </div>
              <div className="btn" style={styles.keyButton} onClick={this.uploadPaymentContract}>
                upload
              </div>
            </div>
            <div style={styles.content}>
            {payment.map((paymentItem, i)=>
              <div style={{...styles.grayRow, backgroundColor: 'rgb( 228, 242, 242 )',}} className={paymentItem==this.state.paymentItem?'selected':''} onClick={()=>this.selectPayment(paymentItem)}>
                <div style={styles.columns.name}>
                  {paymentItem}
                </div>
                <div className="btn" style={styles.columns.delete} onClick={()=>this.deleteItem(paymentItem, 'payment', i)}>
                  del       
                </div>
              </div>            
            )}
            </div>
            <div style={{...styles.label, justifyContent: 'center', width: '100%'}}>payment args</div>            
            <div style={styles.formItem}>
              <input style={styles.input} name="paymentArg" value={this.state.paymentArg} onChange={this.handleChange}/>
            </div>      
          </div>
          <div className="col-xs-12 col-sm-6 col-md-6 col-lg-6 col-md m-b-15">

            <div style={styles.buttonRow}>
              <div style={styles.label}>
                session contracts
              </div>
              <div className="btn" style={styles.keyButton} onClick={this.uploadSessionContract}>
                upload
              </div>
            </div>
            <div style={styles.content}>
            {session.map((sessionItem, i)=>
              <div style={styles.grayRow} className={sessionItem==this.state.sessionItem?'selected':''} onClick={()=>this.selectSession(sessionItem)}>
                <div style={styles.columns.name}>
                  {sessionItem}
                </div>
                <div className="btn" style={styles.columns.delete} onClick={()=>this.deleteItem(sessionItem, 'session', i)}>
                  del       
                </div>
              </div>          
            )}
            </div>
            <div style={{...styles.label, justifyContent: 'center', width: '100%'}}>session args</div>            
            <div style={styles.formItem}>
              <input style={styles.input} name="sessionArg" value={this.state.sessionArg} onChange={this.handleChange}/>
            </div>
          </div>
        </div>
        <div style={styles.container}>
          <div className="form content">
            <div style={{...styles.formItem, justifyContent: 'center'}}>
              <div className="btn" style={styles.keyButton} onClick={this.deployContract}>
                deploy
              </div>
              <div className="btn" style={styles.keyButton} onClick={this.saveContract}>
                save
              </div>
            </div>        
            <div style={{...styles.label, justifyContent: 'center', width: '100%'}}>
              saved
            </div>
            <div style={styles.content}>
            {savedContracts.map((savedContractItem, i)=>
              <div style={{...styles.grayRow, backgroundColor: 'rgb( 228, 228, 228 )',}} className={savedContractItem.name==this.state.savedContractItem.name?'selected':''} onClick={()=>this.selectContract(savedContractItem)}>
                <div style={styles.columns.name}>
                  {savedContractItem.name}
                </div>
                <div className="btn" style={styles.columns.delete} onClick={this.savedDeploy(savedContractItem, i)}>
                  deploy       
                </div>
                <div className="btn" style={styles.columns.delete} onClick={()=>this.deleteContract(savedContractItem, i)}>
                  del       
                </div>
              </div>            
            )}
            </div>

          </div>
        </div>

        <div id="upload-contract-modal" className="modal">
          <div className="modal-content">
            <div className="modal-header">
              <span className="close" onClick={this.closeModal}>&times;</span>
              <h2>upload contract</h2>
            </div>
            <div className="modal-body">
              <div style={styles.formItem}>
                <div style={styles.formLabel}>name:</div>
                <input style={styles.input} id="contract-name" name="newName" value={this.state.newName} onChange={this.handleChange}/>
              </div>
              <div style={{...styles.formItem, justifyContent: 'center'}}>
                <div className="btn" style={styles.browseButton} onClick={this.uploadFile}>
                  browse       
                </div>
                <input hidden type="file" name="wasm" onChange={this.readWasm} id="wasm-file"/>
              </div>
              {this.state.validationError&&<div style={{display: 'flex',justifyContent: 'center'}}><span className="validation">“name” and file must be specified</span></div>}
            </div>
            <div className="modal-footer">
              <div className="btn" style={styles.keyButton} onClick={this.createNewContract}>
                upload       
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


export default Contracts;
