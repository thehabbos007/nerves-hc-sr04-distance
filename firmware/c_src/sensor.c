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
  long startTime = 0, stopTime = 0, difference = 0;
  double rangeCm;
  gpio_write(PIN_TRIGGER, 1);
  usleep(10);
  gpio_write(PIN_TRIGGER, 0);

  while(gpio_read(PIN_ECHO) == 0);

  startTime = getMicrotime();
  while(gpio_read(PIN_ECHO) == 1);
  stopTime = getMicrotime();
  
  difference = stopTime - startTime;
  rangeCm = difference / 58;

  ERL_NIF_TERM atom_ok = enif_make_atom(env, "ok");
  ERL_NIF_TERM double_reading = enif_make_double (env, rangeCm);
  return enif_make_tuple(env, 2, atom_ok, double_reading);
}

static ERL_NIF_TERM init_sensor(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  gpio_export(PIN_TRIGGER);
  gpio_export(PIN_ECHO);
  gpio_direction(PIN_TRIGGER, 1);
  gpio_direction(PIN_ECHO, 0);
  return enif_make_atom(env, "ok");
}

static ErlNifFunc nif_funcs[] =
{
    {"do_sensor_reading", 0, do_sensor_reading, 0},
    {"init_sensor", 0, init_sensor, 0}
};

ERL_NIF_INIT(Elixir.Firmware.Sensor, nif_funcs, NULL,NULL,NULL,NULL)