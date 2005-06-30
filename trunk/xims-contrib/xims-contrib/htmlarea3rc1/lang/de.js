// I18N constants

// LANG: "de", ENCODING: ISO-8859-1 for the german umlaut!

HTMLArea.I18N = {

	// the following should be the filename without .js extension
	// it will be used for automatically load plugin language.
	lang: "de",

	tooltips: {
		bold:           "Fett",
		italic:         "Kursiv",
		underline:      "Unterstrichen",
		strikethrough:  "Durchgestrichen",
		subscript:      "Hochgestellt",
		superscript:    "Tiefgestellt",
        justifyleft:            "Linksbündig",
        justifycenter:          "Zentriert",
        justifyright:           "Rechtsbündig",
		justifyfull:    "Blocksatz",
        orderedlist:      "Nummerierung",
        unorderedlist:    "Aufzählungszeichen",
		outdent:        "Einzug verkleinern",
        indent:                 "Einzug vergrößern",
        forecolor:              "Schriftfarbe",
        backcolor:              "Hindergrundfarbe",
        hilitecolor:            "Hintergrundfarbe",
		horizontalrule: "Horizontale Linie",
        inserthorizontalrule:   "Horizontale Linie",
        createlink:             "Hyperlink einfügen",
        insertimage:            "Bild einfügen",
        inserttable:            "Tabelle einfügen",
		htmlmode:       "HTML Modus",
		popupeditor:    "Editor im Popup öffnen",
        about:                  "Über htmlarea",
        help:                   "Hilfe",
		showhelp:       "Hilfe",
        textindicator:          "Derzeitiger Stil",
        undo:                   "Rückgängig",
		redo:           "Wiederholen",
		cut:            "Ausschneiden",
		copy:           "Kopieren",
        paste:                  "Einfügen aus der Zwischenablage",
        lefttoright:            "Textrichtung von Links nach Rechts",
        righttoleft:            "Textrichtung von Rechts nach Links",
        removeformat:            "Formatierung entfernen",
        killword:                "MSOffice Filter (Entfernt MSOffice spezifische Tags und Attribute)",
        clearfonts:              "Zeichensatzformatierungen entfernen (font-tags)"
	},

 buttons: {
		"ok":           "OK",
		"cancel":       "Abbrechen"
	},

	selectoptions: {
        "&mdash; format &mdash;": "&mdash; Format &mdash;",
        "Heading 1": "Überschrift 1",
        "Heading 2": "Überschrift 2",
        "Heading 3": "Überschrift 3",
        "Heading 4": "Überschrift 4",
        "Heading 5": "Überschrift 5",
        "Heading 6": "Überschrift 6",
        "Normal": "Normal (Absatz)",
        "Address": "Adresse",
        "Formatted": "Formatiert"
	},

	msg: {
		"Path":         "Pfad",
        "TEXT_MODE":            "Sie sind im Text-Modus. Benutzen Sie den [<>] Knopf um in den visuellen Modus (WYSIWYG) zu gelangen.",

        "Moz-Clipboard" :
        "Aus Sicherheitsgründen dürfen Skripte normalerweise nicht programmtechnisch auf " +
        "Ausschneiden/Kopieren/Einfügen zugreifen. Bitte klicken Sie OK um die technische " +
        "Erläuterung auf mozilla.org zu öffnen, in der erklärt wird, wie einem Skript Zugriff " +
        "gewährt werden kann."
    },

    dialogs: {
        "OK":                   "OK",
        "Cancel":               "Abbrechen",
        "Insert/Modify Link":   "Verknüpfung hinzufügen/ändern",
        "None (use implicit)":  "k.A. (implizit)",
        "New window (_blank)":  "Neues Fenster (_blank)",
        "Same frame (_self)":   "Selber Rahmen (_self)",
        "Top frame (_top)":     "Oberster Rahmen (_top)",
        "Other":                "Anderes",
        "Target:":              "Ziel:",
        "Title (tooltip):":     "Titel (Tooltip):",
        "URL:":                 "URL:",
        "You must enter the URL where this link points to": "Sie müssen eine Ziel-URL angeben für die Verknüpfung angeben"
	}
};
