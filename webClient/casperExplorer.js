
rootOptions = {
   el: "body",

   data: {
      chain: [          // for linear chains only; initially an empty array; does this include blocks that are not visible?
         { id: "", rspace: "", deploys: [ { id: "", code: "" }, { id: "", code: "" } ] },  // is id the block hash?
         { id: "", rspace: "", deploys: [ { id: "", code: "" }, { id: "", code: "" } ] }
      ],

      deployBuffer: [            // initially an empty array
         { id: "", code: "" },   // id is user: timestamp (or just timestamp for deploy buffer?)
         { id: "", code: "" }
      ],

      state: ""         // current state of the UI (only textarea?)
   },

   created: function() {
      /* do get /show/chain and set state above, that should reactively render all comps */
   },

   methods: {
      rspaceIconClick: function ( blockID ) {          // rspace diff icon
         /* display diff of rspace of clicked block with previous block */
      },

      deployClick: function ( location, deployID ) {   // deploy comp in either block or deploy buffer
         /* display rholang contained in deploy (on or off chain) in textarea */
      },

      arrowClick: function ( direction ) {             // left and right arrows of chain
         if ( direction == "left" ) {
            if ( leftmostBlock() == "genesis" ) return
            //
         } else if ( direction == "right" ) {
            if ( rightmostBlock() == "head" ) return
            //
         } else {
            console.error( "arrowClick(): invalid direction: " + direction )
         }
      },

      newDeployButtonClick: function () {
         /* clear and focus textarea */
      },

      deployButtonClick: function () {
         /* use current contenxts of textarea append new deploy object to deployBuffer; do put /deploy; clear textarea */
      },

      proposeButtonClick: function () {
         /* do put /block; clear deployBuffer state (will this reactively remove deploy elements on-screen?) */
      },
   }
};

//--- 120 characters -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

deployOptions = {
   props: [ "location", "deploy" ],
   template: `
      <div class='deploy flex' v-on:click='$emit( "deployClick( location, deploy.id )" )'>
         {{ deploy.id }}
      </div>`
};

blockOptions = {
   props: [ "block" ],
   template: `
      <div class='block flexColumn'>
         <div class='heading flexRow'>
            <div class='title'>{{ block.id }}</div>
            <img class='icon' v-on:click='$emit( "rspaceIconClick( block.id )" )' src='rspaceIcon.png'/>
         </div>
         <deploy
            v-for='deploy in block.deploys'
            v-bind:location='#block'   // this is supposed to be an immediate
            v-bind:deploy='deploy'
            v-bind:key='deploy.id'
            v-on:click='$emit( "deployClick( "#block", deploy.id )" )'>
         </deploy>
      </div>`
};

chainOptions = {
   props: [ "chain" ],
   template: `
      <div id='chain' class="flexRow">
         <img v-on:click='$emit( "arrowClick( "#left" )" )' src='leftArrow.png'/>
         <block
            v-for='block in chain'
            v-bind:block='block'
            v-bind:key='block.id'>
         </block>`
         <img v-on:click='$emit( "arrowClick( "#right" )" )' src='rightArrow.png'/>
      </div>`
};

deployBufferOptions = {
   props: [ "deployBuffer" ],
   template: `
      <div id='deploy-buffer'>
         <deploy
            v-for='deploy in deployBuffer'
            v-bind:location='#buffer'      // this is supposed to be an immediate
            v-bind:deploy='deploy'
            v-bind:key='deploy.id'>
            v-on:click='$emit( "deployClick( "#buffer", deploy.id )" )'>   // use index as deploy ID?
         </deploy>
      </div>`
};

textWindowOptions = {
   props: [ "content" ],
   template: `
      <div id='control-panel'>
         <div class='button' v-on:click='$emit( "newDeployButtonClick" )'>new deploy</div>`
         <div class='button' v-on:click='$emit( "deployButtonClick" )'>deploy</div>`
         <div class='button' v-on:click='$emit( "proposeButtonClick" )'>new block</div>`
      </div>
      <textarea></textarea>`
};

Vue.component( "deploy", deployOptions );
Vue.component( "block",  blockOptions  );
Vue.component( "chain",  chainOptions  );
Vue.component( "deploy-buffer", deployBufferOptions );
Vue.component( "text-window",   textWindowOptions   );

vm = new Vue( rootOptions );
