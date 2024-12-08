package cli

import (
	"strings"

	"github.com/charmbracelet/bubbles/help"
	"github.com/charmbracelet/bubbles/key"
	tea "github.com/charmbracelet/bubbletea"
)

type Model struct {
	keys     keyMap
	help     help.Model
	quitting bool
	config   *Config
}

func InitialModel(cfg *Config) Model {
	return Model{
		keys:   keys,
		help:   help.New(),
		config: cfg,
	}
}

type keyMap struct {
	Help key.Binding
	Quit key.Binding
}

func (k keyMap) ShortHelp() []key.Binding {
	return []key.Binding{k.Help, k.Quit}
}

func (k keyMap) FullHelp() [][]key.Binding {
	return [][]key.Binding{
		{k.Help, k.Quit},
	}
}

var keys = keyMap{
	Help: key.NewBinding(
		key.WithKeys("?"),
		key.WithHelp("?", "help"),
	),
	Quit: key.NewBinding(
		key.WithKeys("q", "esc", "ctrl+c"),
		key.WithHelp("q", "quit"),
	),
}

func (m Model) Init() tea.Cmd {
	return nil
}

func (m Model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.KeyMsg:
		switch {
		case key.Matches(msg, m.keys.Help):
			m.help.ShowAll = !m.help.ShowAll
			return m, nil
		case key.Matches(msg, m.keys.Quit):
			m.quitting = true
			return m, tea.Quit
		}
	}
	return m, nil
}

const asciiArt = `
:::::::::  :::        ::::::::  :::::::::  :::::::::  :::    ::: ::::::::::: ::::::::  :::    :::
:+:    :+: :+:       :+:    :+: :+:    :+: :+:    :+: :+:    :+:     :+:    :+:    :+: :+:    :+:
+:+    +:+ +:+       +:+    +:+ +:+    +:+ +:+    +:+ +:+    +:+     +:+    +:+        +:+    +:+
+#++:++#+  +#+       +#+    +:+ +#++:++#+  +#++:++#+  +#++:++#++     +#+    +#++:++#++ +#++:++#++
+#+    +#+ +#+       +#+    +#+ +#+    +#+ +#+        +#+    +#+     +#+           +#+ +#+    +#+
#+#    #+# #+#       #+#    #+# #+#    #+# #+#    #+# #+#        #+#    #+#     #+#    #+#    #+# 
#########  ########## ########  #########  ###        ###    ### ########### ########  ###    ###
`

func (m Model) View() string {
	var s strings.Builder

	// Apply styling to ASCII art
	s.WriteString(DefaultStyles.ASCII.Render(asciiArt))
	s.WriteString("\n\n")

	// Show current command and configuration if present
	if m.config.Command != "" {
		s.WriteString(DefaultStyles.CommandBar.Render("Command: "+m.config.Command) + "\n")
	}

	// Show help
	if m.help.ShowAll {
		s.WriteString("\n" + DefaultStyles.Help.Render(m.help.View(m.keys)))
	}

	// Show quit message
	if m.quitting {
		return DefaultStyles.StatusBar.Render("Goodbye!") + "\n"
	}

	return s.String()
}
