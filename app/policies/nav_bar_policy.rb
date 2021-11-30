class NavBarPolicy < ApplicationPolicy
  def visible_buttons
    visible = Set.new
    visible << (user ? 'Logout' : 'Login')
    visible << 'Sign Up' unless user
    visible.merge %w[Glossary Contributions] if system_settings.peer_to_peer?
    visible.merge %w[Contributions Feedback Matches Admin] if can_admin?
    visible.to_a
  end
end
