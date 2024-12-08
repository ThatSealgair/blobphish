package cli

import (
	"fmt"

	tea "github.com/charmbracelet/bubbletea"
)

func Execute(cfg *Config) error {
	p := tea.NewProgram(InitialModel(cfg))

	if _, err := p.Run(); err != nil {
		return fmt.Errorf("error running program: %v", err)
	}

	return nil
}
