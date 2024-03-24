extends Node

signal block_damaged(position: Vector3i, damager: Node, damage: int)
signal block_broken(position: Vector3i, breaker: Node)
