import React, {Component} from 'react';
import SelectField from 'material-ui/SelectField';
import MenuItem from 'material-ui/MenuItem';
import Services from '../services/services';

const styles = {

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
  form: {
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'space-between',
    marginTop: '14px'
  },
  formItem: {
    backgroundColor: 'rgb(252, 252, 252)',
    margin:10,
    display: 'flex',
    borderRadius: 5,
    justifyContent: 'space-between',
    alignItems: 'center',
    width: '100%'
  },
  input: {
    padding: 6,
    borderRadius: 6,
    float: 'right',
    height: 26,
    width: '100%'
  },
  center: {
    width: '100%',
    justifyContent: 'center'
  },
  cancelButton: {
    backgroundColor:'rgb( 220, 220, 220 )',
    margin: '5px',
    color: 'rgb( 89, 89, 89 )'
  }
};

class Query extends Component {

  constructor(props) {
    super(props);
    this.state = {
      block: '',
      variant: 'address',
      key: '',
      path: '',
      queryName: '',
      savedQueries: []
    };
    this.handleChange = this.handleChange.bind(this);
    this.saveQuery = this.saveQuery.bind(this);
    this.saveQueryModal = this.saveQueryModal.bind(this);
    this.closeModal = this.closeModal.bind(this);
    this.handleVariant = this.handleVariant.bind(this);

  }
  componentDidMount() {
    for (let index = 0; index < document.getElementsByClassName('menu-button').length; index++) {
      document.getElementsByClassName('menu-button')[index].classList.remove('active');
    }
    document.getElementsByClassName('menu-button')[3].classList.add('active');
    let data = JSON.parse(localStorage.getItem("data"));
    this.setState({savedQueries: data.savedQueries});
  }

  handleChange(e) {
    let val = {};
    val[e.target.name] = e.target.value;
    this.setState(val);
  }

  handleVariant(e) {
    let val = {variant: e.target.innerText};
    this.setState(val);
  }

  saveQueryModal() {
    if (this.state.block==''||this.state.variant==''||this.state.key==''||this.state.path=='') {
      alert("All fields are required!");
      return;
    }
    this.setState({validationError: false});
    var modal = document.getElementById("save-query-modal");
    modal.style.display = "block";
  }

  closeModal() {
    this.setState({validationError: false});
    var modal = document.getElementById("save-query-modal");
    modal.style.display = "none";
  }

  saveQuery() {
    if (this.state.queryName=='') {
      this.setState({validationError: true});
      return;
    }
    let queryInfo = {
      name: this.state.queryName,
      block: this.state.block,
      variant: this.state.variant,
      key: this.state.key,
      path: this.state.path
    };
    let that = this;
    Services.saveQuery(queryInfo)
    .then(function(res){
      this.setState({validationError: false});      
      that.closeModal();
      if (res.status) {
        this.setState({outputList: queryInfo});
      }
    })
  }

  render() {

    const {savedQueries} = this.state;

    return ( 
      <div style={styles.container}>
        <div className="form content">
          <div style={styles.formItem}>
            <div style={{...styles.label, justifyContent: 'flex-start'}}>block:</div>      
            <input style={styles.input} name="block" value={this.state.block} onChange={this.handleChange}/>
          </div>
          <div style={styles.formItem}>
            <div style={{...styles.label, justifyContent: 'flex-start'}}>key variant:</div>
              <SelectField
                value={this.state.variant}
                onChange={this.handleVariant}
                floatingLabelText=""
                fullWidth={true}>
                <MenuItem key={0} value="address" primaryText="address"/>
                <MenuItem key={1} value="hash" primaryText="hash"/>
                <MenuItem key={2} value="uref" primaryText="uref"/>
              </SelectField>
          </div>
          <div style={styles.formItem}>
            <div style={{...styles.label, justifyContent: 'flex-start'}}>key:</div>      
            <input style={styles.input} name="key" value={this.state.key} onChange={this.handleChange}/>
          </div>
          <div style={styles.formItem}>
            <div style={{...styles.label, justifyContent: 'flex-start'}}>path:</div>      
            <input style={styles.input} name="path" value={this.state.path} onChange={this.handleChange}/>
          </div>
          <div style={{...styles.formItem, justifyContent: 'center'}}>
            <div className="btn" style={styles.keyButton} onClick={()=>this.saveQueryModal()}>
              query
            </div>
          </div>
          <div style={{...styles.label, justifyContent: 'center', width: '100%'}}>
            output
          </div>
          <div style={{height: 177, border: 'solid #AAA', borderRadius: 10, overflow: 'auto'}}> 
            <div style={styles.content}>
              {savedQueries.map(query=>
                <div style={{...styles.grayRow, backgroundColor: 'rgb( 228, 228, 228 )'}}>
                    {query.name}
                </div>            
              )}
            </div>
          </div>
        </div>

        <div id="save-query-modal" className="modal">
          <div className="modal-content">
            <div className="modal-header">
              <span className="close" onClick={this.closeModal}>&times;</span>
              <h2>save query</h2>
            </div>
            <div className="modal-body">
              <div style={styles.formItem}>
                <div style={styles.formLabel}>name:</div>
                <input style={styles.input} id="contract-name" name="queryName" value={this.state.queryName} onChange={this.handleChange}/>
              </div>
              {this.state.validationError&&<div style={{display: 'flex',justifyContent: 'center'}}><span className="validation">“name” must be specified</span></div>}
            </div>
            <div className="modal-footer">
              <div className="btn" style={styles.keyButton} onClick={this.saveQuery}>
                save       
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


export default Query;
