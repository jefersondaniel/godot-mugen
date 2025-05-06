extends Node2D

func _init() -> void:
    print("Going to load core assets")
    var assets = CoreAssets.load("mugen-data")
    assets.success = false
    print("Success: ", assets.success)
    print("Error message: ", assets.error_message)
    # print(core_assets.configuration)
    # print("Finished loading core assets")

