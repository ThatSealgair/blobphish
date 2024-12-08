package cli

import "github.com/charmbracelet/lipgloss"

type KanagawaTheme struct {
	Background lipgloss.Color
	Foreground lipgloss.Color
	Selection  lipgloss.Color
	Comment    lipgloss.Color
	Red        lipgloss.Color
	Green      lipgloss.Color
	Yellow     lipgloss.Color
	Blue       lipgloss.Color
	Purple     lipgloss.Color
	Cyan       lipgloss.Color
	Orange     lipgloss.Color
}

var Kanagawa = KanagawaTheme{
	Background: lipgloss.Color("#1F1F28"),
	Foreground: lipgloss.Color("#DCD7BA"),
	Selection:  lipgloss.Color("#2D4F67"),
	Comment:    lipgloss.Color("#727169"),
	Red:        lipgloss.Color("#C34043"),
	Green:      lipgloss.Color("#76946A"),
	Yellow:     lipgloss.Color("#C0A36E"),
	Blue:       lipgloss.Color("#7E9CD8"),
	Purple:     lipgloss.Color("#957FB8"),
	Cyan:       lipgloss.Color("#6A9589"),
	Orange:     lipgloss.Color("#FFA066"),
}

var DefaultStyles = struct {
	Title      lipgloss.Style
	ASCII      lipgloss.Style
	Error      lipgloss.Style
	Help       lipgloss.Style
	StatusBar  lipgloss.Style
	CommandBar lipgloss.Style
}{
	Title: lipgloss.NewStyle().
		Foreground(Kanagawa.Blue).
		Bold(true).
		Padding(1),
	ASCII: lipgloss.NewStyle().
		Foreground(Kanagawa.Purple).
		Bold(true),
	Error: lipgloss.NewStyle().
		Foreground(Kanagawa.Red).
		Bold(true),
	Help: lipgloss.NewStyle().
		Foreground(Kanagawa.Comment),
	StatusBar: lipgloss.NewStyle().
		Foreground(Kanagawa.Foreground).
		Background(Kanagawa.Selection).
		Padding(0, 1),
	CommandBar: lipgloss.NewStyle().
		Foreground(Kanagawa.Green),
}
