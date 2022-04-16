version "4.0"

class BuddyWatchHandler : StaticEventHandler
{
	private ui HUDFont MainFont;
	private ui int HealthBars[HDStatusBar.STB_BEATERSIZE * MAXPLAYERS];

	override void RenderOverlay(RenderEvent e)
	{
		if (AutomapActive || GameState != GS_LEVEL)
		{
			return;
		}

		MainFont = HUDFont.Create("SMALLFONT");

		bool OriginalFullscreen = StatusBar.FullscreenOffsets;

		StatusBar.FullscreenOffsets = true;
		vector2 off = (-6, 3);
		for (int i = 0; i < MAXPLAYERS; ++i)
		{
			let plr = HDPlayerPawn(players[i].mo);
			if (!plr || StatusBar.CPlayer.mo == plr)
			{
				continue;
			}

			StatusBar.DrawString(MainFont, plr.player.GetUserName(), off, StatusBar.DI_SCREEN_RIGHT_TOP | StatusBar.DI_TEXT_ALIGN_RIGHT, scale: (0.75, 0.75));
			DrawHealthTicker(StatusBar, plr, (off.x - 8, off.y + 14), StatusBar.DI_SCREEN_RIGHT_TOP);
			StatusBar.DrawString(MainFont, StatusBar.FormatNumber(int(plr.enc), 1, 8), (off.x - 16, off.y + 8), StatusBar.DI_SCREEN_RIGHT_TOP | StatusBar.DI_TEXT_ALIGN_RIGHT, plr.overloaded < 0.8 ? Font.CR_OLIVE : plr.overloaded>1.6 ? Font.CR_RED : Font.CR_GOLD, scale: (0.75, 0.75));
			
			double addOff = off.y + 7 + MainFont.mFont.GetHeight();

			StatusBar.Fill(Color(128, 96, 96, 96), off.x - 14, addOff + 1, -20, 1, StatusBar.DI_SCREEN_RIGHT_TOP | StatusBar.DI_ITEM_RIGHT);
			StatusBar.Fill(Color(128, 96, 96, 96), off.x - 14, addOff + 2, -1, 1, StatusBar.DI_SCREEN_RIGHT_TOP | StatusBar.DI_ITEM_RIGHT);

			StatusBar.Fill(plr.player.GetDisplayColor() | 0xFF000000, off.x - 15, addOff + 2, -min(plr.maxpocketspace, plr.pocketenc) * 19 / plr.maxpocketspace, 1, StatusBar.DI_SCREEN_RIGHT_TOP | StatusBar.DI_ITEM_RIGHT);

			bool overenc = plr.flip && plr.pocketenc > plr.maxpocketspace;
			StatusBar.Fill(overenc ? Color(255, 216, 194, 42) : Color(128, 96, 96, 96), off.x - 34, addOff + 2, overenc ? 2 : 1, 1, StatusBar.DI_SCREEN_RIGHT_TOP | StatusBar.DI_ITEM_RIGHT);
			StatusBar.Fill(Color(128, 96, 96, 96), off.x - 14, addOff + 3, -20, 1, StatusBar.DI_SCREEN_RIGHT_TOP | StatusBar.DI_ITEM_RIGHT);

			off.y += 22;
		}

		StatusBar.FullscreenOffsets = OriginalFullscreen;
	}

	// [Ace] Copy-pasted from HD.
	private ui void DrawHealthTicker(BaseStatusBar sb, HDPlayerPawn plr, vector2 drawpos, int flags)
	{
		Color sbcolour = plr.player.GetDisplayColor();
		int Extra = HDStatusBar.STB_BEATERSIZE * plr.PlayerNumber();
		if (!plr.beatcount)
		{
			for (int i = 0; i < HDStatusBar.STB_BEATERSIZE - 2; ++i)
			{
				HealthBars[Extra + i] = HealthBars[Extra + i + 2];
			}
			int err = max(0, ((100 - plr.health) >> 3));
			err = random[heart](0, err);
			HealthBars[Extra + (HDStatusBar.STB_BEATERSIZE - 2)] = clamp(18 - (plr.bloodloss >> 7) - (err >> 2), 1, 18);
			HealthBars[Extra + (HDStatusBar.STB_BEATERSIZE - 1)] = (plr.inpain ? random[heart](1, 7) : 1) + err + random[heart](0, plr.bloodpressure >> 3);
		}
		
		if (plr.Health <= 0)
		{
			for (int i = 0; i < HDStatusBar.STB_BEATERSIZE; ++i)
			{
				HealthBars[Extra + i] = 1;
			}
		}

		for (int i = 0; i < HDStatusBar.STB_BEATERSIZE; ++i)
		{
			int alf = (i & 1) ? 128 : 255;
			sb.Fill((plr.health > 70 ? color(alf, sbcolour.r, sbcolour.g, sbcolour.b) : plr.health > 33 ? color(alf, 240, 210, 10) : color(alf, 220, 0, 0)), drawpos.x + i - (HDStatusBar.STB_BEATERSIZE >> 2), drawpos.y - HealthBars[Extra + i] * 0.3, 0.8, HealthBars[Extra + i] * 0.6, flags | sb.DI_ITEM_CENTER | (plr.health > 70 ? sb.DI_TRANSLATABLE : 0));
		}
	}
}