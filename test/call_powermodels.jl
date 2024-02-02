@testset "test exported executive functions" begin

    @testset "test for run_powermodels_pf: ac" begin
        result = run_powermodels_pf(case_pf_ac)

        @test string(result["termination_status"]) == "LOCALLY_SOLVED"
        @test isapprox(result["objective"], 0.0; atol = 1e0)
        @test result["solve_time"] > 0.0
    end

    @testset "test for run_powermodels_pf: ac_native" begin
        result = run_powermodels_pf(case_pf_ac_native)
        @test result["termination_status"]
        @test string(result["optimizer"]) == "NLsolve"
        @test isapprox(result["objective"], 0.0; atol = 1e0)
        @test result["solve_time"] >= 0.0
    end

    @testset "test for run_powermodels_opf: ac" begin
        result = run_powermodels_opf(case_opf_ac)

        @test isa(result, Dict{String,Any})
        @test string(result["termination_status"]) == "LOCALLY_SOLVED"

        @test isapprox(result["objective"], 8.0298; atol = 0.1)
        @test result["solve_time"] > 0.0
    end


    # @testset "test for run_powermodels_opf: cl" begin
    #     result = run_powermodels_opf(case_opf_cl)
    #
    #     @test string(result["termination_status"]) == "LOCALLY_SOLVED"
    #     @test isapprox(result["objective"], 17015.5; atol = 1e0)
    #     @test result["solve_time"] > 0.0
    # end

    @testset "test for powermodels_tnep: ac" begin
        result = run_powermodels_tnep(case_tnep_ac)

        @test string(result["termination_status"]) == "LOCALLY_SOLVED"
        @test string(result["dual_status"]) == "NO_SOLUTION"
        @test string(result["primal_status"]) == "FEASIBLE_POINT"

        new_branch = result["solution"]["ne_branch"]
        for idx in keys(new_branch)
            @test isapprox(new_branch[idx]["built"], 0.0, atol=1e-6, rtol=1e-6) ||
                  isapprox(new_branch[idx]["built"], 1.0, atol=1e-6, rtol=1e-6)
        end

        @test isapprox(new_branch["1"]["pt"], -17.0667, atol = 1e-1, rtol = 1e-1)
        @test isapprox(new_branch["2"]["pf"], 15.866, atol = 1e-1, rtol = 1e-1)

        @test isapprox(result["objective_lb"], 60.0; atol = 1e-1)
        @test isapprox(result["objective"], 60.0; atol = 1e-1)

        @test result["solve_time"] > 0.0
    end

    @testset "test for powermodels_dnep_mn_strg: ac" begin
        result = run_powermodels_dnep_mn_strg(case_dnep_mn_strg_ac)

        @test string(result["termination_status"]) == "LOCALLY_SOLVED"
        @test string(result["dual_status"]) == "NO_SOLUTION"
        @test string(result["primal_status"]) == "FEASIBLE_POINT"

        new_branch = result["solution"]["nw"]["1"]["ne_branch"]
        for idx in keys(new_branch)
            @test isapprox(new_branch[idx]["built"], 0.0, atol=1e-6, rtol=1e-6) ||
                  isapprox(new_branch[idx]["built"], 1.0, atol=1e-6, rtol=1e-6)
        end

        branch = result["solution"]["nw"]["1"]["branch"]
        for idx in keys(branch)
            @test isapprox(branch[idx]["rate_add"], 0.0, atol=1e-3, rtol=1e-3)
        end

        @test isapprox(new_branch["1"]["pt"], -26.2741, atol = 1e-1, rtol = 1e-1)
        @test isapprox(new_branch["2"]["pf"], 15.8990, atol = 1e-1, rtol = 1e-1)

        @test isapprox(result["objective_lb"], 180.127; atol = 1e-1)
        @test isapprox(result["objective"], 180.127; atol = 1e-1)

        @test result["solve_time"] > 0.0
    end

    @testset "test for powermodels_dnep_mn_strg_relaxed_with_duals: ac" begin
        result = run_powermodels_dnep_mn_strg_relaxed_with_duals(case_dnep_mn_strg_ac)

        @test string(result["termination_status"]) == "LOCALLY_SOLVED"
        @test string(result["dual_status"]) == "FEASIBLE_POINT"
        @test string(result["primal_status"]) == "FEASIBLE_POINT"

        new_branch = result["solution"]["nw"]["1"]["ne_branch"]
        for idx in keys(new_branch)
            @test isapprox(new_branch[idx]["built"], 0.0, atol=1e-2, rtol=1e-2) ||
                  isapprox(new_branch[idx]["built"], 1.0, atol=1e-2, rtol=1e-2)
        end

        branch = result["solution"]["nw"]["1"]["branch"]
        for idx in keys(branch)
            @test isapprox(branch[idx]["rate_add"], 0.0, atol=1e-3, rtol=1e-3)
            @test haskey(branch[idx], "mu_sm_to")
            @test haskey(branch[idx], "mu_sm_fr")
        end

        @test isapprox(new_branch["1"]["pt"], -26.2741, atol = 1e-1, rtol = 1e-1)
        @test isapprox(new_branch["2"]["pf"], 0, atol = 1e-1, rtol = 1e-1)

        @test isapprox(result["objective_lb"], -Inf; atol = 1e-4)
        @test isapprox(result["objective"], 75.4941; atol = 1e-4)

        @test result["solve_time"] > 0.0
    end

    @testset "test for powermodels_dnep: ac" begin
        result = run_powermodels_dnep(case_dnep_ac)

        @test string(result["termination_status"]) == "LOCALLY_SOLVED"
        @test string(result["dual_status"]) == "NO_SOLUTION"
        @test string(result["primal_status"]) == "FEASIBLE_POINT"

        new_branch = result["solution"]["ne_branch"]
        for idx in keys(new_branch)
            @test isapprox(new_branch[idx]["built"], 0.0, atol=1e-6, rtol=1e-6) ||
                  isapprox(new_branch[idx]["built"], 1.0, atol=1e-6, rtol=1e-6)
        end

        @test isapprox(new_branch["1"]["pf"], 23.4697, atol = 1e-2, rtol = 1e-2)
        @test isapprox(new_branch["2"]["pt"], -12.9853, atol = 1e-2, rtol = 1e-2)

        @test isapprox(result["objective_lb"], 60.0419; atol = 1e-1)
        @test isapprox(result["objective"], 60.0419; atol = 1e-1)

        @test result["solve_time"] > 0.0
    end

    @testset "test for powermodels_dnep_relaxed_with_duals: ac" begin
        result = run_powermodels_dnep_relaxed_with_duals(case_dnep_ac)

        @test string(result["termination_status"]) == "LOCALLY_SOLVED"
        @test string(result["dual_status"]) == "FEASIBLE_POINT"
        @test string(result["primal_status"]) == "FEASIBLE_POINT"

        new_branch = result["solution"]["ne_branch"]
        for idx in keys(new_branch)
            @test isapprox(new_branch[idx]["built"], 0.0, atol=1e-2, rtol=1e-2) ||
                  isapprox(new_branch[idx]["built"], 1.0, atol=1e-2, rtol=1e-2)
        end

        @test isapprox(new_branch["1"]["pf"], 28.19425, atol = 1e-2, rtol = 1e-2)
        @test isapprox(new_branch["2"]["pt"], 0.0, atol = 1e-2, rtol = 1e-2)

        @test isapprox(result["objective_lb"], -Inf; atol = 1e-1)
        @test isapprox(result["objective"], 19.7800; atol = 1e-1)

        @test result["solve_time"] > 0.0
    end

    @testset "test for powermodels_ots: dc" begin
            result = run_powermodels_ots(case_ots_dc)

            @test string(result["termination_status"]) == "LOCALLY_SOLVED"
            @test string(result["dual_status"]) == "NO_SOLUTION"
            @test string(result["primal_status"]) == "FEASIBLE_POINT"

            branch = result["solution"]["branch"]
            # for idx in keys(branch)
            #     @test isapprox(branch[idx]["br_status"], 0.0, atol=1e-6, rtol=1e-6) ||
            #           isapprox(branch[idx]["br_status"], 1.0, atol=1e-6, rtol=1e-6)
            # end
            @test isapprox(result["objective_lb"], 14810.0; atol = 1e0)
            @test isapprox(result["objective"], 14810.0; atol = 1e0)

            @test result["solve_time"] > 0.0
    end

    @testset "test for run_powermodels_multi_storage: ac" begin
            result = run_powermodels_multi_storage(case_multi_storage)
            @test string(result["termination_status"]) == "LOCALLY_SOLVED"
            @test string(result["dual_status"]) == "NO_SOLUTION"
            @test string(result["primal_status"]) == "FEASIBLE_POINT"
            @test string(result["optimizer"]) == "Juniper"
            @test result["solve_time"] > 0.0
    end

end
