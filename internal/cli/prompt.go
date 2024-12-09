// internal/cli/prompt.go
package cli

import (
	"fmt"
	"strings"

	"github.com/charmbracelet/bubbles/key"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

type ProcessAction int

const (
	Continue ProcessAction = iota
	Skip
	Exit
)

type PromptMsg struct {
	Action ProcessAction
}

type PromptModel struct {
	description string
	stepNumber  int
	totalSteps  int
	keys        promptKeyMap
	selected    int
	quitting    bool
}

type promptKeyMap struct {
	Up    key.Binding
	Down  key.Binding
	Enter key.Binding
	Help  key.Binding
	Quit  key.Binding
}

var promptKeys = promptKeyMap{
	Up: key.NewBinding(
		key.WithKeys("up", "k"),
		key.WithHelp("↑/k", "up"),
	),
	Down: key.NewBinding(
		key.WithKeys("down", "j"),
		key.WithHelp("↓/j", "down"),
	),
	Enter: key.NewBinding(
		key.WithKeys("enter"),
		key.WithHelp("enter", "select"),
	),
	Help: key.NewBinding(
		key.WithKeys("?"),
		key.WithHelp("?", "help"),
	),
	Quit: key.NewBinding(
		key.WithKeys("q", "esc", "ctrl+c"),
		key.WithHelp("q", "quit"),
	),
}

func NewProcessPrompt(description string, stepNumber, totalSteps int) PromptModel {
	return PromptModel{
		description: description,
		stepNumber:  stepNumber,
		totalSteps:  totalSteps,
		keys:        promptKeys,
		selected:    0,
	}
}

func (m PromptModel) Init() tea.Cmd {
	return nil
}

func (m PromptModel) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.KeyMsg:
		switch {
		case key.Matches(msg, m.keys.Up):
			m.selected--
			if m.selected < 0 {
				m.selected = 2
			}
			return m, nil

		case key.Matches(msg, m.keys.Down):
			m.selected++
			if m.selected > 2 {
				m.selected = 0
			}
			return m, nil

		case key.Matches(msg, m.keys.Enter):
			return m, func() tea.Msg {
				return PromptMsg{Action: ProcessAction(m.selected)}
			}

		case key.Matches(msg, m.keys.Quit):
			m.quitting = true
			return m, tea.Quit
		}
	}

	return m, nil
}

func (m PromptModel) View() string {
	if m.quitting {
		return DefaultStyles.StatusBar.Render("Process terminated by user") + "\n"
	}

	var s strings.Builder

	// Add step counter
	stepInfo := fmt.Sprintf("Step %d of %d", m.stepNumber, m.totalSteps)
	s.WriteString(DefaultStyles.StatusBar.Render(stepInfo) + "\n\n")

	// Add description
	s.WriteString(DefaultStyles.CommandBar.Render(m.description) + "\n\n")

	// Add options
	options := []string{"Continue to next step", "Skip next step", "Exit process"}
	for i, option := range options {
		cursor := " "
		if m.selected == i {
			cursor = DefaultStyles.Title.Render(">")
		}

		// Style the option based on its type and selection
		optionStyle := lipgloss.NewStyle()
		switch i {
		case 0: // Continue
			optionStyle = optionStyle.Foreground(Kanagawa.Green)
		case 1: // Skip
			optionStyle = optionStyle.Foreground(Kanagawa.Yellow)
		case 2: // Exit
			optionStyle = optionStyle.Foreground(Kanagawa.Red)
		}

		if m.selected == i {
			optionStyle = optionStyle.Bold(true)
		}

		s.WriteString(fmt.Sprintf("%s %s\n", cursor, optionStyle.Render(option)))
	}

	// Add help
	s.WriteString("\n" + DefaultStyles.Help.Render("↑/↓: navigate • enter: select • q: quit"))

	return s.String()
}

// RunProcessPrompt runs the prompt and returns the selected action
func RunProcessPrompt(description string, stepNumber, totalSteps int) (ProcessAction, error) {
	p := tea.NewProgram(NewProcessPrompt(description, stepNumber, totalSteps))
	m, err := p.Run()
	if err != nil {
		return Exit, err
	}

	if m.(PromptModel).quitting {
		return Exit, nil
	}

	return Continue, nil
}
