package;

import kha.Assets;
import kha.Font;
import kha.Framebuffer;
import kha.Image;
import kha.Scheduler;
import kha.System;
import kha.input.Mouse;

using StringTools;

/**
 * ...
 * @author The Mozok Team - Dmitry Hryppa
 */

class Empty 
{
    private var bunnyTex:Array<Image> = [];
    private var font:Font;

    private var bCount:Int = 0;
    private var bunnies:Array<Bunny>;
    private var gravity:Float = 0.5;
    private var maxX:Int;
    private var maxY:Int;
    private var minX:Int;
    private var minY:Int;

    //------------------------------------------------
    private var backgroundColor:Int = 0xFF2A3347;
    private var deltaTime:Float = 0.0;
    private var totalFrames:Int = 0;
    private var elapsedTime:Float = 0.0;
    private var previousTime:Float = 0.0;
    private var fps:Int = 0;
    //------------------------------------------------

    public function new() 
    {
        Assets.loadEverything(function():Void 
        {
            font = Assets.fonts.mainfont;

            for(name in Assets.images.names) {
                if(name.startsWith("wabbit_alpha")) {
                    bunnyTex.push(Assets.images.get(name));
                }
            }
            
            bunnies = new Array<Bunny>();
            minX = 0;
            maxX = Main.SCREEN_W - bunnyTex[0].width;
            minY = 0;
            maxY = Main.SCREEN_H - bunnyTex[0].height;
            
            
            Mouse.get().notify(mouseDown, null, null, null);
            Scheduler.addTimeTask(update, 0, 1/60);
            System.notifyOnRender(render);
        });
    }

    private function mouseDown(button:Int, x:Int, y:Int):Void 
    {
        var count:Int = 10; // button == 0 ? 10000 : 1000;
        for (i in 0...count) {
            var bunny:Bunny = new Bunny();
            bunny.speedX = Math.random() * 5;
            bunny.speedY = Math.random() * 5 - 2.5;
            bunnies.push(bunny);
        }
        bCount = bunnies.length;
    }

    private function update():Void 
    {
        for (i in 0...bunnies.length) {
            var bunny:Bunny = bunnies[i];
            
            bunny.x += bunny.speedX;
            bunny.y += bunny.speedY;
            bunny.speedY += gravity;
            
            if (bunny.x > maxX) {
                bunny.speedX *= -1;
                bunny.x = maxX;
            } else if (bunny.x < minX) {
                bunny.speedX *= -1;
                bunny.x = minX;
            } if (bunny.y > maxY) {
                bunny.speedY *= -0.8;
                bunny.y = maxY;
                if (Math.random() > 0.5) bunny.speedY -= 3 + Math.random() * 4;
            }  else if (bunny.y < minY) {
                bunny.speedY = 0;
                bunny.y = minY;
            }
        }
    }

    public function render(framebuffer:Framebuffer):Void 
    {
        var currentTime:Float = Scheduler.realTime();
        deltaTime = (currentTime - previousTime);
        
        elapsedTime += deltaTime;
        if (elapsedTime >= 1.0) {
            fps = totalFrames;
            totalFrames = 0;
            elapsedTime = 0;
        }
        totalFrames++;
        
        framebuffer.g2.begin(true, backgroundColor);
        framebuffer.g2.color = 0xFFFFFFFF;
        var i = 0;
        for (bunny in bunnies){
            if(i >= bunnyTex.length) {
                throw "Need more textures for this bunny count";
            }
            framebuffer.g2.drawImage(bunnyTex[i], bunny.x, bunny.y);
            i++;
        }
        
        framebuffer.g2.font = font;
        framebuffer.g2.fontSize = 16;
        framebuffer.g2.color = 0xFF000000;
        framebuffer.g2.fillRect(0, 0, Main.SCREEN_W, 20);
        framebuffer.g2.color = 0xFFFFFFFF;
        framebuffer.g2.drawString("bunnies: " + bCount + "         fps: " + fps, 10, 2);
        framebuffer.g2.end();
        
        previousTime = currentTime;
    }
}
