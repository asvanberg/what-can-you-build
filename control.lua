local function show_gui(player)
  local frame = player.gui.relative.add({
    type = "frame",
    name = "wcyb-main-frame",
    direction = "vertical",
    style = "inner_frame_in_outer_frame",
    anchor = {
      gui = defines.relative_gui_type.logistic_gui,
      position = defines.relative_gui_position.right
    }
  })
  build_titlebar(frame)

  local inner_frame = frame.add({
    type = "frame",
    style = "inside_deep_frame"
  })

  local scroll_pane = inner_frame.add({
    type = "scroll-pane"
  })
  scroll_pane.style.vertically_stretchable = true
  scroll_pane.style.padding = {4, 8}

  local table_gui = scroll_pane.add({
    type = "flow",
    direction = "vertical"
  })
  table_gui.style.vertical_spacing = 8
  table_gui.style.horizontally_stretchable = true

  local networks = player.force.logistic_networks[player.surface.name]
  local function is_mobile(network)
    for _, cell in ipairs(network.cells) do
      if cell.mobile then return true end
    end
    return false
  end
  local stationary_networks = {}
  for _, network in pairs(networks) do
    if not is_mobile(network) then
      table.insert(stationary_networks, network)
    end
  end

  local function has_item(prototype_name)
    for _, network in pairs(stationary_networks) do
      if network.get_contents()[prototype_name] then return true end
    end
    return false
  end

  for name, recipe in pairs(player.force.recipes) do
    if recipe.enabled and not recipe.hidden then
      for _, product in pairs(recipe.products) do
        if product.type == "item" then
          local item_prototype = game.item_prototypes[product.name]
          if item_prototype.place_result and not has_item(product.name) then
            local has_all_ingredients = true
            for _, ingredient in pairs(recipe.ingredients) do
              has_all_ingredients = has_all_ingredients and has_item(ingredient.name)
            end
            if has_all_ingredients then
              local entry = table_gui.add({
                type = "flow",
                style = "centering_horizontal_flow"
              })
              entry.style.horizontal_spacing = 8
              entry.add({
                type = "sprite",
                sprite = "item/" .. product.name,
                tooltip = item_prototype.localised_name
              })
              entry.add({
                type = "label",
                caption = item_prototype.localised_name
              })
            end
          end
        end
      end
    end
  end
end

function build_titlebar(frame)
  local flow = frame.add({
    name = "titlebar",
    type = "flow",
    direction = "horizontal",
  })
  flow.style.horizontal_spacing = 8

  flow.add({
    type = "label",
    style = "frame_title",
    caption = "What can you build",
    ignored_by_interaction = true
  })
end

script.on_event(defines.events.on_gui_opened, function(event)
  if event.gui_type == defines.gui_type.logistic then
    local player = game.get_player(event.player_index)
    local frame = player.gui.relative["wcyb-main-frame"]
    if not frame or not frame.valid then
      show_gui(player)
    end
  end
end)

script.on_event(defines.events.on_gui_closed, function(event)
  if event.gui_type == defines.gui_type.logistic then
    local player = game.get_player(event.player_index)
    local frame = player.gui.relative["wcyb-main-frame"]
    if frame and frame.valid then
      frame.destroy()
    end
  end
end)
