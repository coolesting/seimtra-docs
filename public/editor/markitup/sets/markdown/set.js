// -------------------------------------------------------------------
// markItUp!
// -------------------------------------------------------------------
// Copyright (C) 2008 Jay Salvat
// http://markitup.jaysalvat.com/
// -------------------------------------------------------------------
// MarkMin tags example
// http://web2py.com/examples/static/markmin.html
//
// file created by Massimo Di Pierro
// -------------------------------------------------------------------
// Feel free to add more tags
// -------------------------------------------------------------------
mySettings = {
	previewParserPath:	'',
	onShiftEnter:		{keepDefault:false, openWith:'\n\n'},
	markupSet: [
		{name:'Heading 1', className:'e-h1', key:'1', openWith:'# ', placeHolder:'Chapter' },
		{name:'Heading 2', className:'e-h2', key:'2', openWith:'## ', placeHolder:'Section' },
		{name:'Heading 3', className:'e-h3', key:'3', openWith:'### ', placeHolder:'Subsection' },
		{name:'Headmenu', dropMenu: [
				{name:'Heading 4', className:'e-h4', key:'4', openWith:'#### ', placeHolder:'SubSubsection' },
				{name:'Heading 5', className:'e-h5', key:'5', openWith:'##### ', placeHolder:'SubSubsection' },
				{name:'Heading 6', className:'e-h6', key:'6', openWith:'###### ', placeHolder:'SubSubsection' },
  			]
		},
		{separator:'---------------' },		
		{name:'Bold', className:'e-b', key:'B', openWith:'**', closeWith:'**'},
		{name:'Italic', className:'e-i', key:'I', openWith:"''", closeWith:"''"},
		{separator:'---------------' },
		{name:'Bulleted List', className:'e-ul', openWith:'- ' },
		{name:'Numeric List', className:'e-ol', openWith:'+' },
		{separator:'---------------' },
		{name:'Picture', className:'e-picture', key:'P', replaceWith:'[[[![Alternative text]!] [![Url:!:http://]!] center]]'},
		{name:'Link', className:'e-link', key:'L', openWith:'[[', closeWith:' [![Url:!:http://]!]]]', placeHolder:'Your text to link here...' },
		{separator:'---------------'},
		{name:'Quotes', className:'e-quotes', openWith:'-------\n', closeWith:'\n-------\n'},
		{name:'Code Block / Code', className:'e-code', openWith:'```\n', closeWith:'\n```'},
		{name:"Upload", className:'e-upload'},
	]
}

// mIu nameSpace to avoid conflict.
miu = {
    markminTitle: function(markItUp, char) {
	heading = '';
	n = $.trim(markItUp.selection||markItUp.placeHolder).length;
	for(i = 0; i < n; i++) {
	    heading += char;
	}
	return '\n'+heading;
    }
}
