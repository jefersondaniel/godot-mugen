extends SceneTree

var sff_parser = load('res://source/native/sff_parser.gdns').new()

func _init():
    pass
    # var metadata_v1 = sff_parser.read_metadata('res://data/chars/GORO/goro.sff')
    # print(metadata_v1)

    # var palette = sff_parser.read_palette('res://data/chars/GORO/Goro1.act')
    # # print(palette[1])
    # var start_time = OS.get_system_time_msecs()
    # var result = sff_parser.read_images("res://data/chars/GORO/goro.sff", palette, PoolIntArray([0]))
    # var end_time = OS.get_system_time_msecs()
    # print(end_time - start_time)
    # print(result)
    # result["0-0"]['image'].save_png('res://test/goro_0_0.png')

    # var palettes = sff_parser.read_palettes('res://data/chars/kfm/kfm.sff')
    # print(palettes)
    # var metadata_v2 = sff_parser.read_metadata('res://data/chars/kfm/kfm.sff')
    # print(metadata_v2)
    # var start_time = OS.get_system_time_msecs()
    # var lala = sff_parser.read_images('res://data/chars/kfm/kfm.sff', palettes[3], PoolIntArray([0]));
    # lala['0-0']['image'].save_png('res://test/kfm_0_0.png')
    # print(lala)
    # var end_time = OS.get_system_time_msecs()
    # print(end_time - start_time)

    # var lala
    # # lala = sffParser.get_images('res://data/chars/kfm/kfm.sff', 5);
    # # lala['0-0']['image'].save_png('res://test/kfm_0_0.png')
    # var start_time = OS.get_system_time_msecs()
    # lala = sffParser.get_images('res://data/chars/GORO/goro.sff', 'res://data/chars/GORO/Goro1.act');
    # var end_time = OS.get_system_time_msecs()
    # print(end_time - start_time)
    # # lala['0-0']['image'].save_png('res://test/goro_0_0.png')
