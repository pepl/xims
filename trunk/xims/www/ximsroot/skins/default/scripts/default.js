/*
# Copyright (c) 2002-2006 The XIMS Project.
# See the file "LICENSE" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# $Id$
*/

agent = navigator.userAgent
browser = 0
selected = ''
if (agent.indexOf("a/3",1) == 6 || agent.indexOf("a/4",1) == 6 || agent.indexOf("a/5",1) == 6) {browser = 1} else {browser = 0}

// Cache Image

if (browser == 1) {
    /* Back, Forward, Up Dir */

    back_n = new Image(38,34);
    back_n.src = "/ximsroot/skins/default/images/navigate-back.png";
    back_h = new Image(38,34);
    back_h.src = "/ximsroot/skins/default/images/navigate-back.png";
    back_s = new Image(38,34);
    back_s.src = "/ximsroot/skins/default/images/navigate-back.png";
    back_c = new Image(38,34);
    back_c.src = "/ximsroot/skins/default/images/navigate-back.png";

    up_n = new Image(31,36);
    up_n.src = "/ximsroot/skins/default/images/navigate-up.png";
    up_h = new Image(31,36);
    up_h.src = "/ximsroot/skins/default/images/navigate-up.png";
    up_s = new Image(31,36);
    up_s.src = "/ximsroot/skins/default/images/navigate-up.png";
    up_c = new Image(31,36);
    up_c.src = "/ximsroot/skins/default/images/navigate-up.png";

    forward_n = new Image(31,36);
    forward_n.src = "/ximsroot/skins/default/images/navigate-forward.png";
    forward_h = new Image(31,36);
    forward_h.src = "/ximsroot/skins/default/images/navigate-forward.png";
    forward_s = new Image(31,36);
    forward_s.src = "/ximsroot/skins/default/images/navigate-forward.png";
    forward_c = new Image(31,36);
    forward_c.src = "/ximsroot/skins/default/images/navigate-forward.png";

    move_h = new Image(32,19);
    move_h.src = "/ximsroot/skins/default/images/option_move_over.png";
    move_s = new Image(32,19);
    move_s.src = "/ximsroot/skins/default/images/option_move_click.png";
    move_c = new Image(32,19);
    move_c.src = "/ximsroot/skins/default/images/option_move.png";

    edit_h = new Image(32,19);
    edit_h.src = "/ximsroot/skins/default/images/option_edit_over.png";
    edit_s = new Image(32,19);
    edit_s.src = "/ximsroot/skins/default/images/option_edit_click.png";
    edit_c = new Image(32,19);
    edit_c.src = "/ximsroot/skins/default/images/option_edit.png";

    delete_h = new Image(37,19);
    delete_h.src = "/ximsroot/skins/default/images/option_delete_over.png";
    delete_s = new Image(37,19);
    delete_s.src = "/ximsroot/skins/default/images/option_delete_click.png";
    delete_c = new Image(37,19);
    delete_c.src = "/ximsroot/skins/default/images/option_delete.png";

    publish_c = new Image(32,19);
    publish_c.src = "/ximsroot/skins/default/images/option_pub.png";

    acl_c = new Image(32,19);
    acl_c.src = "/ximsroot/skins/default/images/option_acl.png";
}

//Animate Button

function pass(button,action,type,input) {
    if (browser == 1) {
        document.images[button].src = eval(action + "_" + type + ".src");
    }
}
