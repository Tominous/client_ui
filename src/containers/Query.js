import React, {Component} from 'react';

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

// const keyList = [
//   {value:'address', name: 'address'},
//   {value:'hash', name: 'hash'},
//   {value:'uref', name: 'uref'}
// ]
class Query extends Component {

  constructor(props) {
    super(props);
    this.state = {
      block: '',
      variant: false,
      key: 'payment',
      path: ''
    };
    this.handleChange = this.handleChange.bind(this);

  }
  componentDidMount() {
    for (let index = 0; index < document.getElementsByClassName('menu-button').length; index++) {
      document.getElementsByClassName('menu-button')[index].classList.remove('active');
    }
    document.getElementsByClassName('menu-button')[3].classList.add('active');
  }

  handleChange(e) {
    let val = {};
    val[e.target.name] = e.target.value;
    this.setState(val);
  }

  render() { 
    return ( 
      <div>
        <div className="row">
          <div className="col-xs-12 col-sm-6 col-md-6 col-lg-6 col-md m-b-15">
            <div style={styles.buttonRow}>
              <div style={{...styles.label, justifyContent: 'center', width: '100%'}}>block:</div>            
              <div style={styles.formItem}>
                <div style={{...styles.label, justifyContent: 'flex-start'}}>block:</div>      
                <input style={styles.input} name="block" value={this.state.block} onChange={this.handleChange}/>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
}


export default Query;
