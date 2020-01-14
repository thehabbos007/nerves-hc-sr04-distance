#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <time.h>
#include <math.h>
#include <erl_nif.h>
#include "gpiolib.h"

#define PIN_TRIGGER 24 // GPIO24, j8 5
#define PIN_ECHO    23 // GPIO23, j8 4

long getMicrotime(){
  long micros;
  time_t s;
  struct timespec spec;
  clock_gettime(CLOCK_REALTIME, &spec);

  s = spec.tv_sec;
  micros = round(spec.tv_nsec / 1.0e3); // Convert nanoseconds to microseconds
    if (micros > 999999) {
        s++;
        micros = 0;
    }

  return s * (int)1e6 + micros;
}


static ERL_NIF_TERM do_sensor_reading(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{

  // printf("Start: %ld, stop: %ld, difference: %ld, range: %.2f cm\n", startTime, stopTime, difference, rangeCm);
  /*gpio_export(PIN_TRIGGER);
  gpio_direction(PIN_TRIGGER, 1);

  for(int i = 0; i < 5; i++) {
    printf(">> GPIO %d ON\n", PIN_TRIGGER);
    gpio_write(PIN_TRIGGER, 1);

    sleep(1);

    printf(">> GPIO %d OFF\n", PIN_TRIGGER);
    gpio_write(PIN_TRIGGER, 0);

    sleep(1);
  }*/

  gpio_export(PIN_TRIGGER);
  gpio_export(PIN_ECHO);
  gpio_direction(PIN_TRIGGER, 1);
  //gpio_write(PIN_TRIGGER, 0);
  gpio_direction(PIN_ECHO, 0);


  gpio_write(PIN_TRIGGER, 1);
  usleep(10);
  gpio_write(PIN_TRIGGER, 0);

  int echo, previousEcho, lowHigh, highLow;
  long startTime = 0, stopTime = 0, difference = 0;
  double rangeCm;
  lowHigh = highLow = echo = previousEcho = 0;
  while(0 == lowHigh || highLow == 0) {
    previousEcho = echo;
    echo = gpio_read(PIN_ECHO);
    if(0 == lowHigh && 0 == previousEcho && 1 == echo) {
      lowHigh = 1;
      startTime = getMicrotime();
    }
    if(1 == lowHigh && 1 == previousEcho && 0 == echo) {
      highLow = 1;
      stopTime = getMicrotime();
    }
  }
  difference = stopTime - startTime;
  rangeCm = difference / 58;

  ERL_NIF_TERM atom_ok = enif_make_atom(env, "ok");
  ERL_NIF_TERM double_reading = enif_make_double (env, rangeCm);
  return enif_make_tuple(env, 2, atom_ok, double_reading);
}

static ErlNifFunc nif_funcs[] =
{
    {"do_sensor_reading", 0, do_sensor_reading, 0}
};

ERL_NIF_INIT(Elixir.Firmware.Sensor, nif_funcs, NULL,NULL,NULL,NULL)