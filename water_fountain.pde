ArrayList<Particle> particles;
Box box;
Fountain fountain;
boolean flowing = false;
float rx = 0, ry = 0, rz = 0, scale = 1;
void setup(){
  size(800, 800, P3D);
  noStroke();
  frameRate(30);
  box = new Box();
  fountain = new Fountain();
  lights();
  particles = new ArrayList<Particle>();
}

void draw(){  
  background(255);
  lights();
  translate(width/2, height/2, 0);
  fill(0);
  text(particles.size(),200,-200); 
  rotateX(rx);
  rotateY(ry);
  rotateZ(rz);
  scale(scale);
  fountain.display();
  if(flowing){
    for(int i = 0; i < 63; i++){
      if(particles.size() < 10000){
       particles.add(new Particle(new PVector(0,-30,0),new PVector(random(0.2,.9),random(-2,-1.9),random(-0.1,0.1))));
      }
    }
  }
  if(keyPressed){
    if(key == 'z'){
      scale-=0.01;
    }
    if(key == 'x'){
      scale+=0.01;
    }
    if(keyCode == UP){
      rx += 0.01;
    }
    if(keyCode == DOWN){
      rx -= 0.01;
    }
    if(keyCode == LEFT){
     // println(ry);
      ry -= 0.01;
    }
    if(keyCode == RIGHT){
      ry += 0.01;
    }
  
  }
  for(int i = particles.size() - 1; i >= 0; i--){
    Particle p = particles.get(i);
    p.update();
    p.display();  
    p.checkEdges();
    if(p.finished()){
      particles.remove(i);
    }
  }
  box.display();
    
}
void keyPressed(){
  println(keyCode);
  if(keyCode == 83 && !flowing){
    flowing = true;
  }
  else if(keyCode == 83 && flowing){
    flowing = false;
  }
  println(flowing);
}
class Fountain{
  PShape fountain;
  PVector location;
  
  Fountain(){
    fountain = loadShape("fountain.obj");
    location = new PVector(0,0,150);
  }
  
  void display(){
    rotateX(1.5708);
    translate(0,0,-150);
    shape(fountain,location.x,location.y,200,200);
    translate(0,0,150);
    rotateX(-1.5708);
  }
}
    
class Particle{
  PVector location;
  PVector velocity;
  PVector acceleration;
  PVector[][] sphere_arr;
  int total = 5;
  float radius;
  float mass;
  float life;
  color col = color(0,0,255,life);
   
  Particle(PVector loc, PVector vel){
    velocity = new PVector(vel.x,vel.y,vel.z);
    acceleration = new PVector(0,0.05,0);
    mass = random(10);
    radius = mass / 5;
    location = new PVector(loc.x,loc.y,loc.z);
    life = 255;
    sphere_arr = new PVector[total + 1][total + 1];
  }
  
  void applyForce(PVector force){
    PVector f = PVector.div(force,mass);
    acceleration.add(f);
  }
  
  void update(){
    velocity.add(acceleration); 
    location.add(velocity);
   // acceleration.mult(0);
    life-=random(1,2);
  }
  
  //This bit of code has been used from this program by Dan Shiffman
  //https://github.com/CodingTrain/website/blob/master/CodingChallenges/CC_025_SphereGeometry/Processing/CC_025_SphereGeometry/CC_025_SphereGeometry.pde
  void display(){
   float r = radius;
   for (int i = 0; i < total+1; i++) {
    float lat = map(i, 0, total, 0, PI);
    for (int j = 0; j < total+1; j++) {
      float lon = map(j, 0, total, 0, TWO_PI);
      float x = r * sin(lat) * cos(lon);
      float y = r * sin(lat) * sin(lon);
      float z = r * cos(lat);
      sphere_arr[i][j] = new PVector(x, y, z);
     }
   }
   for (int i = 0; i < total; i++) { 
    fill(0,0,random(200,255),life*3);
    noStroke();
   
    beginShape(TRIANGLE_STRIP);
   // texture(img);
    for (int j = 0; j < total+1; j++) {
      PVector v1 = sphere_arr[i][j];
      vertex(v1.x + location.x, v1.y + location.y, v1.z + location.z);
      PVector v2 = sphere_arr[i+1][j];
      vertex(v2.x + location.x, v2.y + location.y, v2.z + location.z);
      }
     endShape();
    }   
  }
  void checkEdges(){
    
    // Check collision with fountain
    if(location.x < 25 && location.y > -20){
      location.y = -20 + radius;
      velocity.y *= random(-.2,-.1);
    }
    if((location.x < 40 && location.y > 35)){
      location.y = 35 + radius;
      velocity.y*= random(-.3,-.1);
    }
    if((location.x + radius < 90) && (location.y + radius > 125)){
      location.y = 125 + radius;
      velocity.y*=random(-0.6,-0.3);
    }
    if((location.x - radius < 90) && (location.x + radius > 80) && (location.y + radius > 120)){
      location.y = 115 + radius;
      velocity.y*=random(-0.3,-0.1);
    }

    // check collision with floor and sides of box
    if(location.x + radius > 150){
      location.x = 150 - radius;
      velocity.x *= random(-.75,-.95);
    }
    if(location.x - radius < -150){
      location.x = -150 + radius;
      velocity.x *= random(-.75,-.95);
    }
    if(location.y + radius > 150){
      location.y = 150 - radius;
      velocity.y *= random(-.5,-.1);
    }
    if(location.y - radius < -150){
      location.y = -150 + radius;
      velocity.y *= random(-.5,-.1);
    }
    if(location.z + radius > 150){
      location.z = 150 - radius;
      velocity.z *= random(-.75,-.95);
    }
    if(location.z - radius < -150){
      location.z = -150 + radius;
      velocity.z *= random(-.75,-.95);
    }
   
  }
  boolean finished(){
    if(life < 0.0){
      return true;
    }else{
      return false;
    }
  } 
}

// The cube for which the particles are bounded to 
class Box{
  float hit = 0;
  void display(){
    // x right
 
    beginShape(QUADS);
    stroke(0);
    noFill();
    vertex( 150, -150,  150, 0, 0); 
    vertex( 150, -150, -150, 150, 0); 
    vertex( 150,  150, -150, 150, 150); 
    vertex( 150,  150,  150, 0, 150); 

    vertex(-150, -150, -150, 0, 0); 
    vertex(-150, -150,  150, 150, 0); 
    vertex(-150,  150,  150, 150, 150); 
    vertex(-150,  150, -150, 0, 150); 

    vertex(-150,  150,  150, 0, 0); 
    vertex( 150,  150,  150, 150, 0); 
    vertex( 150,  150, -150, 150, 150); 
    vertex(-150,  150, -150, 0, 150); 

    vertex(-150, -150, -150, 0, 0); 
    vertex( 150, -150, -150, 150, 0); 
    vertex( 150, -150,  150, 150, 150); 
    vertex(-150, -150,  150, 0, 150);


    vertex(-150,-150,150,0,0);
    vertex(150,-150,150,150,0);
    vertex(150,150,150,150,150);
    vertex(-150,150,150,0,150);

    vertex(150,-150,-150,0,0);
    vertex(-150,-150,-150,150,0);
    vertex(-150,150,-150,150,150);
    vertex(150,150,-150,0,150);
    endShape();

  }
}
