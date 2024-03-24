{ colors }:

''
background = {
  monitor =
  color = rgba(25, 20, 20, 1.0)

  blur_passes = 0
  blur_size = 7
  noise = 0.0117
  contrast = 0.8916
  brightness = 0.8172
  vibrancy = 0.1696
  vibrancy_darkness = 0.0
}

input-field {
  monitor = 
  size = 300, 50
  outline_thickness = 3
  dots_size = 0.33
  dots_spacing = 0.15
  dots_center = false
  dots_rounding = -1
  outer_color = rgb(${colors.base04})
  inner_color = rgb(${colors.base00})
  font_color = rgb(${colors.base05})
  fade_on_empty = true
  fade_timeout = 1000
  placeholder_text =
  hide_input = false
  rounding = -1
  check_color = rgb(${colors.base01})
  fail_color = rgb(${colors.base08})
  fail_text =
  fail_transition = 300

  position = 0, -20
  halign = center
  valign = center
}
''