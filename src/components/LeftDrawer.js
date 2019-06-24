import React,  { PropTypes } from 'react';
import Drawer from 'material-ui/Drawer';
import {spacing, typography} from 'material-ui/styles';
import {white, blue600} from 'material-ui/styles/colors';
import MenuItem from 'material-ui/MenuItem';
import {Link} from 'react-router';

const LeftDrawer = (props) => {
  let { navDrawerOpen } = props;

  const styles = {
    logo: {
      cursor: 'pointer',
      fontSize: 18,
      color: typography.textFullWhite,
      lineHeight: `${spacing.desktopKeylineIncrement}px`,
      fontWeight: typography.fontWeightLight,
      backgroundColor: blue600,
      paddingLeft: 40,
      height: 56,
    },
    menuItem: {
      color: white,
      fontSize: 18
    },
    avatar: {
      div: {
        margin: '31px 31px 31px 53px',
        backgroundImage:  'url(' + require('../images/casper_labs_log.png') + ')',
        height: '138px',
        backgroundSize: 'contain',
        'backgroundRepeat': 'no-repeat'
      },
      icon: {
        float: 'left',
        display: 'block',
        marginRight: 15,
        boxShadow: '0px 0px 0px 8px rgba(0,0,0,0.2)'
      },
      span: {
        paddingTop: 12,
        display: 'block',
        color: 'white',
        fontWeight: 300,
        textShadow: '1px 1px #444'
      }
    },
    getStarted: {
      backgroundColor: 'rgb( 236, 87, 72 )',
      fontSize: 18,
      padding: '7px 17px',
      borderRadius: 13,
      border: 'none',
      color: 'white',
      margin: 31
    },
    menuButton: {
      display: 'flex',
      justifyContent: 'center'
    }
  };

  return (
    <Drawer
      docked={true}
      open={navDrawerOpen}>
        <div style={styles.avatar.div}>
        </div>
        <div>
          <div style={styles.menuButton}>
            <button type="button" style={styles.getStarted}>get started</button>
          </div>
          {props.menus.map((menu, index) =>
            <div style={styles.menuButton} className="menu-button">
              <MenuItem
                key={index}
                style={styles.menuItem}
                primaryText={menu.text}
                leftIcon={menu.icon}
                containerElement={<Link to={menu.link}/>}
              />
            </div>
          )}
        </div>
    </Drawer>
  );
};

LeftDrawer.propTypes = {
  navDrawerOpen: PropTypes.bool,
  menus: PropTypes.array,
  username: PropTypes.string,
};

export default LeftDrawer;
