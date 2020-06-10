# Proj1

**
  Group Members            
  Gurpreet Singh Nagpal: 0698-9051  
  Maharshi Rawal: 9990-8457    
**

**TODO: The goal of this first project is to use Elixir and the actor model to build a good solution to the vampire number problem that runs well on multi-core machines.
**

1. Problem definition

An interesting kind of number in mathematics is vampire number (Links to an external site.). A vampire number is a composite (Links to an external site.) natural number (Links to an external site.) with an even number of digits, that can be factored into two natural numbers each with half as many digits as the original number and not both with trailing zeroes, where the two factors contain precisely all the digits of the original number, in any order, counting multiplicity.  A classic example is: 1260= 21 x 60.

A vampire number can have multiple distinct pairs of fangs. A vampire numbers with 2 pairs of fangs is: 125460 = 204 × 615 = 246 × 510.

The goal of this first project is to use Elixir and the actor model to build a good solution to this problem that runs well on multi-core machines.

 

2. Requirements

Input: The input provided (as command line to your program, e.g. my_app) will be two numbers: N1 and N2. The overall goal of your program is to find all vampire numbers starting at N1 and up to N2.

Output: Print, on independent lines, first the number then its fangs. If there are multiple fangs list all of them next to each other like it’s shown in the example below.

Your File name should be proj1.

Example 1:

mix run proj1.exs 100000 200000

125460 204 615 246 510

This output indicates that a vampire number between 100000 and 200000 is 125460 and its possible pair of fangs are: 204, 615 and 246, 510.

 

Actor modeling: In this project, you must use exclusively the actor facility in Elixir (projects that do not use multiple actors or use any other form of parallelism will receive no credit). In particular, define worker actors that are given a range of problems to solve and a boss that keeps track of all the problems and perform the job assignment.

## Steps to run

  To run the program: mix run proj1.exs lower_bound upper_bound for e.g. mix run proj1.exs 100000 200000. To run with time information run the program as: time mix run proj1.exs 100000 200000.

  1) The number of worker actors created were dependent on the range of the input:  
      For the numbers between a range with difference between upper bound [UB] and lower bound [LB] less than 10000, we have a chunk of 1000 numbers solved by one worker.  
      No. of workers = (Upper Bound - Lower Bound) / Chunk Size  
      So for range [1000 to 10000], we have (10000 - 1000) / 1000 = 9 Workers  
      Similarly for larger ranges, we have selected chunk size as 10000 [UB - LB > 10000 ], 25000 [UB - LB > 100000], 100000 [UB - LB > 10000000]

  2) Size of Work Unit is also dependent on the range. As explained in the point above, since the number of workers created are dependent on the range, their work units also differ for different ranges.  
  For example for a range between 100000 to 200000, we tried these three sub-unit sizes: 10000, 14000, 20000. The system performed the best on the problem with sub-unit size of 10000.

  These were the results for range 100000 to 200000 using three different work units  

    For 10000:   real	0m1.754s   user	0m3.982s   sys 0m0.170s  
    cpu ratio: 2.36  

    For 14000:   real	0m1.717s   user	0m3.806s   sys 0m0.144s
    cpu ratio: 2.30

    For 20000:   real	0m1.666s   user	0m3.545s   sys 0m0.144s
    cpu ratio: 2.22

  
  3) For larger inputs: 10000000 to 20000000, the cpu ratio achieved was 3.69

    real	3m55.232s   user	14m23.795s   sys 0m4.858s

  4) Largest problem solved: 10000000 to 20000000

  **All these tests were run on a laptop with Intel Core i5-5200U processor with 2 physical cores and 4 threads.