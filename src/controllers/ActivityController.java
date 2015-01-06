/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package controllers;

import data.AbstractRepository;
import data.ActivityRepository;
import data.RepositoryFactory;
import java.util.Map;
import models.Activity;

/**
 *
 * @author mendes
 */
public class ActivityController extends AbstractController<Activity> {
    ActivityRepository repo;
    
    ActivityController() {
        this.repo = RepositoryFactory.getActivityRepository();
    }
    
    @Override
    public Activity newInstance(Map<String, Object> params) {
        return new Activity( (String)params.get("name") );
    }

    @Override
    protected AbstractRepository<Activity> getRepository() {
        return RepositoryFactory.getActivityRepository();
    }
}
