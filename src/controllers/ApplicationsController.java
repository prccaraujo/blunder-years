/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package controllers;

import data.ApplicationRepository;
import data.DataException;
import data.RepositoryFactory;
import java.util.Map;
import models.Application;

/**
 *
 * @author frmendes
 */
public class ApplicationsController extends AbstractController<Application> {
    ApplicationRepository repo;

    ApplicationsController() {
        this.repo = RepositoryFactory.getApplicationRepository();
    }

    @Override
    public Application newInstance(final Map<String, Object> params) throws DataException {
        return new Application(
                (String)params.get("applicationDate"),
                (String)params.get("file"),
                (Integer)params.get("priority"),
                (String)params.get("notes"),
                (String)params.get("location"),
                (Integer)params.get("manager"),
                (Integer)params.get("familyId")
        );
    }

    protected ApplicationRepository getRepository() {
        return RepositoryFactory.getApplicationRepository();
    }  
}
