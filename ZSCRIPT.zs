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
			int elementsoff = 4;
			if (cvar.getcvar("cl_buddyekg", players[consoleplayer]).getbool())
			{
				DrawHealthTicker(StatusBar, plr, (off.x - (elementsoff + 4), off.y + 14), StatusBar.DI_SCREEN_RIGHT_TOP);
				elementsoff += 8;
			}
			
			if (cvar.getcvar("cl_buddybulk", players[consoleplayer]).getbool())
			{
				StatusBar.DrawString(MainFont, StatusBar.FormatNumber(int(plr.enc), 1, 8), (off.x - (elementsoff + 2), off.y + 8), StatusBar.DI_SCREEN_RIGHT_TOP | StatusBar.DI_TEXT_ALIGN_RIGHT, plr.overloaded < 0.8 ? Font.CR_OLIVE : plr.overloaded>1.6 ? Font.CR_RED : Font.CR_GOLD, scale: (0.75, 0.75));
				double addOff = off.y + 7 + MainFont.mFont.GetHeight();

				StatusBar.Fill(Color(128, 96, 96, 96), off.x - elementsoff, addOff + 1, -20, 1, StatusBar.DI_SCREEN_RIGHT_TOP | StatusBar.DI_ITEM_RIGHT);
				StatusBar.Fill(Color(128, 96, 96, 96), off.x - elementsoff, addOff + 2, -1, 1, StatusBar.DI_SCREEN_RIGHT_TOP | StatusBar.DI_ITEM_RIGHT);

				StatusBar.Fill(plr.player.GetDisplayColor() | 0xFF000000, off.x - (elementsoff + 1), addOff + 2, -min(plr.maxpocketspace, plr.pocketenc) * 19 / plr.maxpocketspace, 1, StatusBar.DI_SCREEN_RIGHT_TOP | StatusBar.DI_ITEM_RIGHT);

				bool overenc = plr.flip && plr.pocketenc > plr.maxpocketspace;
				StatusBar.Fill(overenc ? Color(255, 216, 194, 42) : Color(128, 96, 96, 96), off.x - (elementsoff + 20), addOff + 2, overenc ? 2 : 1, 1, StatusBar.DI_SCREEN_RIGHT_TOP | StatusBar.DI_ITEM_RIGHT);
				StatusBar.Fill(Color(128, 96, 96, 96), off.x - elementsoff, addOff + 3, -20, 1, StatusBar.DI_SCREEN_RIGHT_TOP | StatusBar.DI_ITEM_RIGHT);
				
				elementsoff += 20;
			}
			
			if (cvar.getcvar("cl_buddymug", players[consoleplayer]).getbool())
			{
				drawmugshot(statusbar, plr, (off.x - (elementsoff + 10), off.y + 20), statusbar.DI_SCREEN_RIGHT_TOP);
			}
			
			off.y += 22;
		}

		StatusBar.FullscreenOffsets = OriginalFullscreen;
	}

	private ui void drawmugshot(basestatusbar sb, hdplayerpawn plr, vector2 drawpos, int flags)
	{
		string mug = "";
		if(plr.mugshot==HDMUGSHOT_DEFAULT)
		{
			switch(plr.player.getgender())
			{
				case 0:
				{
					mug = "STF";
					break;
				}
				case 1: 
				{
					mug = "SFF";
					break;
				}
				default: 
				{
					mug = "STC";
					break;
				}
			}
		}
		else 
		{
			mug = plr.mugshot;
		}
		
		string suffix = "ST"..(4 - min(plr.health / 20, 4)).."1";
		if (plr.health < 1)
		{
			suffix = "DEAD0";
		}
		
		sb.DrawTexture(texman.checkfortexture(mug..suffix), drawpos, flags, 1, (-1, -1), (0.4, 0.4));
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
