# Copyright (c) Meta Platforms, Inc. and affiliates.
# All rights reserved.

# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

using LinearAlgebra
using JuMP
using Hypatia
using SparseArrays
using CSV, Tables

cd(string(ARGS[1], "/seed_", ARGS[2], "/"))

valuations = Matrix{Float64}(
    CSV.read("valuations.csv", Tables.matrix, header=0)
);
budget_notification_types = Matrix{Float64}(
    transpose(CSV.read("budget_notification_types.csv", Tables.matrix, header=0))
);
budget_platform = Float64(
    CSV.read("budget_platform.csv", Tables.matrix, header=0)[1]
);
supply_num_user_slots = vec(
    CSV.read("supply_num_user_slots.csv", Tables.matrix, header=0)
);

num_notification_types = Int(maximum(valuations[:,1]));
num_users = Int(maximum(valuations[:,2]));
num_pairs = size(valuations, 1);

println("number of notification types: ", num_notification_types);
println("number of users: ", num_users);
println("number of pairs: ", num_pairs);

# setup JuMP model
opt = Hypatia.Optimizer(verbose = true);
model = Model(() -> opt);
# model = Model(HiGHS.Optimizer)

# add variables
@variable(model, x[1:num_pairs] .>= 0);
@variable(model, u[1:num_notification_types]);
@variable(model, ulog[1:num_notification_types]);
@variable(model, p);
@variable(model, plog >= 0);

# supply constraints
S = sparse(
    valuations[:,2],
    Array(1:num_pairs),
    ones(num_pairs)
)
SUP_constr = @constraint(model, S * x .<= supply_num_user_slots);

# box constraints
AMO_constr = @constraint(model, x .<= 1);

# constraints for utilities of notification types and platform
U = sparse(
    valuations[:,1],
    Array(1:num_pairs),
    valuations[:,3]
);
P = sparse(
    ones(num_pairs),
    Array(1:num_pairs),
    valuations[:,4]
);
@constraint(model, U*x .== u);
@constraint(model, P*x .== p);

# constraints for utilities to the power of budgets for all
# ExponentialCone: {(x,y,z): y*exp(x/y)<=z, y>=0}
for i in 1:num_notification_types
    @constraint(
        model, 
        vcat(ulog[i], 1, u[i]) in MOI.ExponentialCone()
    )
end
@constraint(
    model, 
    vcat(plog, 1, p) in MOI.ExponentialCone()
);

# objective
@objective(
    model, 
    Max, 
    sum(ulog.*vec(budget_notification_types)) + plog*budget_platform
);

# solve
@time optimize!(model);

# print information of the solution
print(termination_status(model))
print(objective_value(model))

# write results to file
CSV.write("alloc.csv",  Tables.table(value.(x)), writeheader=false);
CSV.write("AMO_dual.csv",  Tables.table(dual.(AMO_constr)), writeheader=false);
CSV.write("SUP_dual.csv",  Tables.table(dual.(SUP_constr)), writeheader=false);

