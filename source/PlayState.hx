package;

import lime.math.Vector2;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxState;


class PlayState extends FlxState
{
	private var right_panel_width = 250;

	private var player:FlxSprite;
	public var player_speed = 300;
	public var player_color = FlxColor.CYAN;
	public var player_height = 15;
	public var player_width = 100;
	public var player_ground_distance = 35;
	public var player_angle_change_ceil = 30;

	public var ball:FlxSprite;
	public var ball_size = 10;
	public var ball_initial_high = 50;
	public var ball_color = FlxColor.GRAY;

	public var ball_speed = 200;
	public var ball_down = 1.0;
	public var ball_right = 1.0;

	public var wall_width = 10;
	public var wall_color = FlxColor.WHITE;
	private var walls: List<FlxSprite>;

	private var limit_left = 0;
	private var limit_right = 0;
	private var limit_top = 0;

	public var top_block_position = 50;
	public var block_distance = 5;
	public var blocks_per_line = 10;
	public var blocks_lines = 10;
	public var block_colors = [FlxColor.RED, FlxColor.BLUE, FlxColor.GREEN, FlxColor.PURPLE, FlxColor.YELLOW];
	public var blocks: List<FlxSprite>;

	override public function create()
	{
		super.create();
		walls = new List<FlxSprite>();
		blocks = new List<FlxSprite>();

		create_walls();
		create_player();
		create_blocks();
		create_ball();
	}

	private function create_walls() {
		if (!walls.isEmpty()) {
			// delete walls
		}
		var game_width = FlxG.width - right_panel_width;

		var wall_left = new FlxSprite(0, 0);
		wall_left.makeGraphic(wall_width, FlxG.height, wall_color);
		add(wall_left);
		walls.add(wall_left);

		var wall_top = new FlxSprite(wall_width, 0);
		wall_top.makeGraphic(game_width - wall_width * 2, wall_width, wall_color);
		add(wall_top);
		walls.add(wall_top);

		var wall_right = new FlxSprite(game_width - wall_width, 0);
		wall_right.makeGraphic(wall_width, FlxG.height, wall_color);
		add(wall_right);
		walls.add(wall_right);

		limit_left = wall_width;
		limit_top = wall_width;
		limit_right = game_width - wall_width;
	}

	private function create_player() {
		if (player != null) {
			// delete player
		}
		player = new FlxSprite((FlxG.width - right_panel_width)/2-player_width/2, FlxG.height - player_ground_distance - player_height);
		player.makeGraphic(player_width, player_height, player_color);
		add(player);
	}

	private function create_blocks() {
		var width = limit_right - limit_left;
		var block_width = (width - block_distance * (blocks_per_line +1)) / (blocks_per_line + 0.5);
		var block_height = block_width / 3;
		var half_block = block_width / 2;

		var shift = false;
		for(line in 0...blocks_lines) {
			var base = shift ? half_block : 0;
			shift = !shift;
			var top = limit_top + top_block_position + line * (block_height + block_distance);
			for (i in 0...blocks_per_line) {
				var block = new FlxSprite(limit_left + block_distance + base + i * (block_width + block_distance), top);
				block.makeGraphic(Std.int(block_width), Std.int(block_height), block_colors[(i + line) % block_colors.length]);
				blocks.add(block);
				add(block);
			}
		}
	}

	private function create_ball() {
		ball = new FlxSprite((FlxG.width - right_panel_width)/2-ball_size/2, player.y - ball_initial_high);
		ball.makeGraphic(ball_size, ball_size, ball_color);
		add(ball);

		ball_down = Math.abs(ball_down) * -1;
		ball_right = Math.abs(ball_right);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		
		var left = FlxG.keys.anyPressed([LEFT, A]);
		var right = FlxG.keys.anyPressed([RIGHT, D]);

		if (left != right) {
			var speed = player_speed;
			var move = (left ? -speed : speed) * elapsed;

			var x = player.x + move;
			if (x < limit_left) {
				x = limit_left;
			} else if (x + player_width > limit_right) {
				x = limit_right - player_width;
			}

			player.x = x;
		}

		var bx = ball.x;
		var by = ball.y;

		var v = new Vector2(ball_right, ball_down);
		v.normalize(1);

		bx += (ball_speed * elapsed) * v.x;
		by += (ball_speed * elapsed) * v.y;

		if (bx < limit_left) {
			ball_right = Math.abs(ball_right);
			bx = limit_left + (limit_left - bx);
		}

		if (bx + ball_size > limit_right) {
			ball_right = Math.abs(ball_right)*-1;
			bx = limit_right - (limit_right - bx);
		}

		if (by < limit_top) {
			ball_down = Math.abs(ball_down);
			by = limit_top + (limit_top - by);
		}

		for (block in blocks) {
			var ball_b = by + ball.height;
			var ball_r = bx + ball.width;
			var block_b = block.y + block.height;
			var block_r = block.x + block.width;

			var to_remove = true;

			if (block_b > ball.y &&
				block_b < ball_b &&
				block_r > ball.x &&
				block.x < ball_r) {
				// hit from bottom
				ball_down = Math.abs(ball_down);
				by = block_b + (block_b - by);
			} else if (
				block.x < ball_r &&
				block.x > ball.x &&
				block.y < ball_b &&
				block_b > ball.y) {
				// hit from left
				ball_right = Math.abs(ball_right)  *-1;
				bx = block.x + (bx - block.x);
			} else if (
				block_r > ball.x &&
				block_r < ball_r &&
				block.y < ball_b &&
				block_b > ball.y) {
				// hit from right
				ball_right = Math.abs(ball_right);
				bx = block_r + (block_r - ball.x);
			} else if (
				block.y < ball_b &&
				block.y > ball.y &&
				block_r > ball.x &&
				block.x < ball_r) {
				// hit from top
				ball_down = Math.abs(ball_down) *-1;
				by = block.y + (by - block.y);
			} else if (
				block.x < ball.x &&
				block_r > ball_r &&
				block.y < ball.y &&
				block_b > ball_b) {
				// got inside
				// ??

			} else {
				to_remove = false;
			}

			if (to_remove) {
				remove(block);
				blocks.remove(block);
			}
		}

		if (bx < player.x + player.width &&
			bx + ball.width > player.x &&
			by < player.y &&
			by + ball.height > player.y) {
				// hit player
				var bd = Math.abs(ball_down) *-1;
				var br = ball_right;
				by = player.y + (ball.y - player.y);

				var angle = PointToAngle(new Vector2(br, -bd));
				var diff = (((bx + ball.width / 2 - player.x) / player_width) - 0.5) * 2;
				angle -= diff * player_angle_change_ceil;
				v = AngleToPoint(angle);

				ball_down = -v.y;
				ball_right = v.x;
			}

		ball.x = bx;
		ball.y = by;

		if (ball.y > FlxG.width) {
			trace("game over");
		}
	}

	private function PointToAngle(v: Vector2):Float {
		var radian = Math.atan2(v.y, v.x);
		return radian * 180 / Math.PI;
	}

	private function AngleToPoint(angle:Float):Vector2 {
		var radian = Math.PI / 180 * angle;
		return new Vector2(Math.cos(radian), Math.sin(radian));
	}
}
