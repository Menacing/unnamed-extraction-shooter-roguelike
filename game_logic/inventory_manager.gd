extends Node


func _ready() -> void:
	EventBus.pickup_item.connect(_on_pickup_item)
	EventBus.add_inventory.connect(add_inventory)
	EventBus.item_durability_changed.connect(_destroy_depleted_durability)
	SaveManager.game_saving.connect(_on_game_saving)
	SaveManager.game_before_loading.connect(_on_game_before_loading)

func _on_pickup_item(item_inst:ItemInstance, target_inventory_id:int) -> void:
	#Are we dealing with a stack or not
	var inventory:Inventory = InventoryAccess.get_inventory(target_inventory_id)
	var _item_instance_id:int = item_inst.item_instance_id
	if inventory == null:
		return
	if !item_inst.get_has_stacks():
		#First check item slots
		if inventory.equipment_slots:
			for slot in inventory.equipment_slots:
				if InventoryAccess.can_place_item_in_slot(item_inst, target_inventory_id, slot.name):
					var pickup_result:InventoryInsertResult = InventoryInsertResult.new(item_inst,target_inventory_id,InventoryLocationResult.new())
					pickup_result.picked_up = InventoryAccess.place_item_in_slot(item_inst, target_inventory_id, slot.name)
					pickup_result.location.location = InventoryLocationResult.LocationType.SLOT
					pickup_result.location.slot_name = slot.name
					EventBus.item_picked_up.emit(pickup_result)
					return
	#
		#Next try to insert in first grid space
		for y in range(inventory.get_height()):
			for x in range(inventory.get_width()):
				var grid_loc := Vector2i(x,y)
				if InventoryAccess.can_place_item_in_grid(item_inst, target_inventory_id, grid_loc):
					var pickup_result:InventoryInsertResult = InventoryInsertResult.new(item_inst,target_inventory_id,InventoryLocationResult.new())
					pickup_result.picked_up = InventoryAccess.place_item_in_grid(item_inst, target_inventory_id, grid_loc)
					pickup_result.location.location = InventoryLocationResult.LocationType.GRID
					pickup_result.location.grid_x = grid_loc.x
					pickup_result.location.grid_y = grid_loc.y
					EventBus.item_picked_up.emit(pickup_result)
					return
		##TODO try rotating and repeating
	#do stack stuff
	else:
		#First check item slots
		var amount:int = item_inst.stacks
		if inventory.equipment_slots:
			for slot in inventory.equipment_slots:
				if item_inst.stacks > 0 and  InventoryAccess.can_place_stack_in_slot(item_inst, target_inventory_id, slot.name):
					var pickup_result:InventoryInsertResult = InventoryInsertResult.new(item_inst,target_inventory_id,InventoryLocationResult.new())					
					pickup_result.picked_up = InventoryAccess.place_stack_in_slot(item_inst, target_inventory_id, slot.name, item_inst.stacks)
					pickup_result.location.location = InventoryLocationResult.LocationType.SLOT
					pickup_result.location.slot_name = slot.name
					EventBus.item_picked_up.emit(pickup_result)
					_destroy_empty_stack(item_inst)
					if pickup_result.picked_up:
						return

		#Next try to insert in first grid space
		for y in range(inventory.get_height()):
			for x in range(inventory.get_width()):
				var grid_loc := Vector2i(x,y)
				if item_inst.stacks > 0 and InventoryAccess.can_place_stack_in_grid(item_inst, target_inventory_id, grid_loc):
					var pickup_result:InventoryInsertResult = InventoryInsertResult.new(item_inst,target_inventory_id,InventoryLocationResult.new())
					pickup_result.picked_up = InventoryAccess.place_stack_in_grid(item_inst, target_inventory_id, grid_loc, item_inst.stacks)
					pickup_result.location.location = InventoryLocationResult.LocationType.GRID
					pickup_result.location.grid_x = grid_loc.x
					pickup_result.location.grid_y = grid_loc.y
					EventBus.item_picked_up.emit(pickup_result)
					_destroy_empty_stack(item_inst)
					if pickup_result.picked_up:
						return

		##TODO try rotating and repeating
	pass

func place_item_in_inventory(item_instance_id:int, target_inventory_id:int) -> void:
	var item_inst = ItemAccess.get_item_instance(item_instance_id)
	_on_pickup_item(item_inst, target_inventory_id)

func can_place_item_in_inventory(item_instance_id:int, target_inventory_id:int) -> bool:
	#Are we dealing with a stack or not
	var item_inst:ItemInstance = ItemAccess.get_item_instance(item_instance_id)
	var inventory:Inventory = InventoryAccess.get_inventory(target_inventory_id)
	if inventory == null:
		return false
	if !item_inst.get_has_stacks():
		#First check item slots
		if inventory.equipment_slots:
			for slot in inventory.equipment_slots:
				if InventoryAccess.can_place_item_in_slot(item_inst, target_inventory_id, slot.name):
					return true
	#
		#Next try to insert in first grid space
		for y in range(inventory.get_height()):
			for x in range(inventory.get_width()):
				var grid_loc := Vector2i(x,y)
				if InventoryAccess.can_place_item_in_grid(item_inst, target_inventory_id, grid_loc):
					return true
		##TODO try rotating and repeating
	#do stack stuff
	else:
		#First check item slots
		var amount:int = item_inst.stacks
		if inventory.equipment_slots:
			for slot in inventory.equipment_slots:
				if item_inst.stacks > 0 and  InventoryAccess.can_place_stack_in_slot(item_inst, target_inventory_id, slot.name):
					return true

		#Next try to insert in first grid space
		for y in range(inventory.get_height()):
			for x in range(inventory.get_width()):
				var grid_loc := Vector2i(x,y)
				if item_inst.stacks > 0 and InventoryAccess.can_place_stack_in_grid(item_inst, target_inventory_id, grid_loc):
					return true
		##TODO try rotating and repeating
	return false

func can_place_item_in_slot(item_instance_id:int, target_inventory_id:int, slot_name:String) -> bool:
	return InventoryAccess.can_place_item_in_slot(get_item(item_instance_id), target_inventory_id, slot_name)

func can_place_stack_in_slot(item_instance_id:int, target_inventory_id:int, slot_name:String, _amount:int) -> bool:
	return InventoryAccess.can_place_stack_in_slot(get_item(item_instance_id), target_inventory_id, slot_name)
	
func place_item_in_slot(item_instance_id:int, target_inventory_id:int, slot_name:String) -> void:
	var item_inst:ItemInstance = get_item(item_instance_id)
	var pickup_result:InventoryInsertResult = InventoryInsertResult.new(item_inst,target_inventory_id, InventoryLocationResult.new())
	pickup_result.location.location = InventoryLocationResult.LocationType.SLOT
	pickup_result.location.slot_name = slot_name
	pickup_result.picked_up = InventoryAccess.place_item_in_slot(item_inst, target_inventory_id, slot_name)
	
	EventBus.item_picked_up.emit(pickup_result)
	
func place_stack_in_slot(item_instance_id:int, target_inventory_id:int, slot_name:String, amount: int) -> void:
	var item_inst:ItemInstance = get_item(item_instance_id)
	var pickup_result:InventoryInsertResult = InventoryInsertResult.new(item_inst,target_inventory_id, InventoryLocationResult.new())
	pickup_result.location.location = InventoryLocationResult.LocationType.SLOT
	pickup_result.location.slot_name = slot_name
	pickup_result.picked_up = InventoryAccess.place_stack_in_slot(item_inst, target_inventory_id, slot_name, amount)
	EventBus.item_picked_up.emit(pickup_result)
	_destroy_empty_stack(item_inst)

	
func can_place_item_in_grid(item_instance_id:int, target_inventory_id:int, grid_location:Vector2i) -> bool:
	var item_inst := get_item(item_instance_id)	
	return InventoryAccess.can_place_item_in_grid(item_inst, target_inventory_id, grid_location)
	
func item_at_position_goes_beyond_point(item_instance_id:int, grid_location:Vector2i, threshold_point:Vector2i) -> bool:
	var item_inst := get_item(item_instance_id)
	#subtract 1 from each axis because we're converting size to coordinates
	var item_size = Vector2i(item_inst.get_width()-1, item_inst.get_height()-1)
	var far_bound = item_size + grid_location
	if far_bound.y >= threshold_point.y and far_bound.x >= threshold_point.x:
		return true
	else:
		return false
	

func can_place_stack_in_grid(item_instance_id:int, target_inventory_id:int, grid_location:Vector2i, _amount:int) -> bool:
	var item_inst := get_item(item_instance_id)	
	return InventoryAccess.can_place_stack_in_grid(item_inst, target_inventory_id, grid_location)
	
func place_item_in_grid(item_instance_id:int, target_inventory_id:int, grid_location:Vector2i) -> void:
	var item_inst := get_item(item_instance_id)
	var pickup_result:InventoryInsertResult = InventoryInsertResult.new(item_inst,target_inventory_id, InventoryLocationResult.new())
	pickup_result.location.location = InventoryLocationResult.LocationType.GRID
	pickup_result.location.grid_x = grid_location.x
	pickup_result.location.grid_y = grid_location.y
	pickup_result.picked_up = InventoryAccess.place_item_in_grid(item_inst, target_inventory_id, grid_location)
	
	EventBus.item_picked_up.emit(pickup_result)
	
func place_stack_in_grid(item_instance_id:int, target_inventory_id:int, grid_location:Vector2i, amount: int) -> void:
	var item_inst := get_item(item_instance_id)
	var pickup_result:InventoryInsertResult = InventoryInsertResult.new(item_inst,target_inventory_id, InventoryLocationResult.new())
	pickup_result.location.location = InventoryLocationResult.LocationType.GRID
	pickup_result.location.grid_x = grid_location.x
	pickup_result.location.grid_y = grid_location.y
	pickup_result.picked_up = InventoryAccess.place_stack_in_grid(item_inst, target_inventory_id, grid_location, amount)
	EventBus.item_picked_up.emit(pickup_result)
	_destroy_empty_stack(item_inst)
	
func find_clear_area_in_grid(item_instance_id:int, target_inventory_id:int) -> Vector2IResult:
	var result := Vector2IResult.new()
	var inventory:Inventory = InventoryAccess.get_inventory(target_inventory_id)
	var item_inst := ItemAccess.get_item_instance(item_instance_id)
	if inventory and item_inst:
		for y in range(inventory.get_height()):
			for x in range(inventory.get_width()):
				var grid_loc := Vector2i(x,y)
				if InventoryAccess.can_place_item_in_grid(item_inst, target_inventory_id, grid_loc):
					result.value = grid_loc
					result.result = true
					return result
	return result
	
func _destroy_empty_stack(item_instance:ItemInstance) -> void:
	if item_instance and item_instance.get_has_stacks():
		if item_instance.stacks <= 0:
			destroy_item(item_instance.item_instance_id)
			
func _destroy_depleted_durability(item_instance:ItemInstance) -> void:
	if item_instance and item_instance.get_has_durability():
		if item_instance.durability <= 0:
			destroy_item(item_instance.item_instance_id)

func add_inventory(inventory:Inventory) -> void:
	InventoryAccess.add_inventory(inventory)
	
func inventory_exists(inventory_id:int) -> bool:
	return InventoryAccess.get_inventory(inventory_id) != null

func remove_item(item_instance_id:int, source_inventory_id:int) -> void:
	var item_inst:ItemInstance = get_item(item_instance_id)	
	InventoryAccess.remove_item(item_inst, source_inventory_id)
	

func destroy_item(item_instance_id:int) -> void:
	var item_inst:ItemInstance = get_item(item_instance_id)		
	if item_inst.current_inventory_id != 0:
		remove_item(item_instance_id, item_inst.current_inventory_id)
	ItemAccess.destroy_item(item_inst)
	
func get_item(item_instance_id:int) -> ItemInstance:
	return ItemAccess.get_item_instance(item_instance_id)

func get_item_information(item_type_id:String) -> ItemInformation:
	return ItemAccess.get_item_information(item_type_id)

func set_inventory_size(inventory_id:int, size:Vector2i) -> void:
	var inventory:Inventory = InventoryAccess.get_inventory(inventory_id)
	var current_width:int = inventory.get_width()
	var current_height:int = inventory.get_height()
	
	#copy old dictionary
	var old_dictionary:Dictionary = inventory.grid_slots
	#create new inventory dictionary
	var new_dictionary:Dictionary = inventory.create_new_grid_slots(size.x, size.y)
	
	#Copy from old dictionary to new
	for cw in range(current_width):
		for ch in range(current_height):
			#if old spot doesn't exist, trigger drop of item
			var item_inst =  old_dictionary[cw][ch]
			if cw > size.x or ch > size.y and item_inst:
				var original_inventory_id = item_inst.current_inventory_id
				remove_item(item_inst.item_instance_id, inventory_id)
				EventBus.drop_item.emit(item_inst, original_inventory_id)
			elif item_inst:
				new_dictionary[cw][ch] = item_inst
	
	#set new dictionary
	inventory.grid_slots = new_dictionary
	
	#set new size
	inventory._current_height = size.y
	inventory._current_width = size.x
	EventBus.inventory_size_changed.emit(inventory_id, size)

func spawn_from_item3d(item3d:Item3D):
	ItemAccess.spawn_from_item3d(item3d)
	
func spawn_from_item_type_id(item_type_id:String) -> ItemInstance:
	return ItemAccess.spawn_from_item_type_id(item_type_id)

func number_item_type_in_inventory(inventory_id:int, item_type_id:String) -> int:
	var count := 0
	var inventory:Inventory = InventoryAccess.get_inventory(inventory_id)
	if item_type_id and inventory:

		#check slots
		for slot in inventory.equipment_slots:
			if slot.item_instance_id != 0:
				var item_inst = ItemAccess.get_item_instance(slot.item_instance_id)
				if item_inst.get_item_type_id() == item_type_id:
					count += 1

		#check grid
		var checked_item_instance_ids:Array[int] = []
		for w in inventory.grid_slots:
			for h in inventory.grid_slots[w]:
				var grid_value:ItemInstance = inventory.grid_slots[w][h]
				if grid_value :
					if grid_value.get_item_type_id() == item_type_id and !checked_item_instance_ids.has(grid_value.item_instance_id):
						count += 1
						checked_item_instance_ids.append(grid_value)
		
	return count

func _on_game_saving(save_file:SaveFile):
	for inv_id in InventoryAccess.inventories:
		save_file.inventories.append(InventoryAccess.inventories[inv_id])

func _on_game_before_loading():
	InventoryAccess.inventories = {}
	
func _on_load_game(save_file:SaveFile):
	for inv:Inventory in save_file.inventories:
		InventoryAccess.inventories[inv.inventory_id] = inv

##only call during game save loading
func _restore_inventories():
	for inv_id in InventoryAccess.inventories.keys():
		var inv:Inventory = InventoryAccess.inventories[inv_id]
		var items_in_inv := InventoryAccess._report_inventory_contents(inv)
		for key in items_in_inv.keys():
			var iir:InventoryInsertResult = items_in_inv[key]
			var item_inst:ItemInstance = ItemAccess.get_item_instance(iir.item_instance_id)
			item_inst.spawn_item()
			EventBus.item_picked_up.emit(iir)
