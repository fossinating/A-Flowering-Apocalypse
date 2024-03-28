extends Node

signal block_damaged(position: Vector3i, damager: Node, damage: int)
signal block_broken(position: Vector3i, breaker: Node)
signal entity_attacked(attacker: Node, attacked: Node, damage: float)
signal entity_killed(killer: Node, killed: Node)
signal item_picked_up(dropped_item: DroppedItem, remainder: int)
